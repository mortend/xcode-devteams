#import <AppKit/NSApplication.h>
#import <Foundation/NSObjCRuntime.h>
#import <Security/SecItem.h>

#include <stdio.h>

void print(FILE *fp, NSString *format, ...) {
    va_list args;
    va_start(args, format);
    NSString *result = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    NSData *bytes = [result dataUsingEncoding:NSUTF8StringEncoding];
    fwrite([bytes bytes], 1, [bytes length], fp);
}

bool isCodeSigningUsage(NSData* data) {
    static UInt8 codeSigningUsageBytes[] = {
        0x2b, 0x6, 0x1, 0x5, 0x5, 0x7, 0x3, 0x3
    };

    if ([data length] != sizeof(codeSigningUsageBytes))
        return false;

    return memcmp([data bytes], codeSigningUsageBytes, sizeof(codeSigningUsageBytes)) == 0;
}

NSString *findValue(NSArray *x509Values, NSString *key) {
    for (NSDictionary *value in x509Values) {
        NSString *valueLabel = (NSString *)value[(id)kSecPropertyKeyLabel];

        if ([valueLabel compare:key] == NSOrderedSame)
            return (NSString*)value[(id)kSecPropertyKeyValue];
    }

    return nil;
}

NSDictionary *parseDevelopmentTeam(SecCertificateRef certificate) {
    NSDictionary *certificateValues = (NSDictionary *)SecCertificateCopyValues(certificate, NULL, NULL);

    if (certificateValues == nil) {
        print(stderr, @"Failed to copy values from certificate");
        return nil;
    }

    // Check if Extended Key Usage is Codesigning
    NSDictionary *extendedKeyUsage = (NSDictionary *)certificateValues[(id)kSecOIDExtendedKeyUsage];

    if (extendedKeyUsage == nil)
         return nil;

    NSArray *extendedKeyUsageValues = (NSArray *)extendedKeyUsage[(id)kSecPropertyKeyValue];

    for (NSData* keyUsageData in extendedKeyUsageValues) {
        if (!isCodeSigningUsage(keyUsageData))
            return nil;
    }

    NSDictionary *x509SubName = (NSDictionary *)certificateValues[(id)kSecOIDX509V1SubjectName];
    NSArray *x509Values = (NSArray *)x509SubName[(id)kSecPropertyKeyValue];

    NSString *ouId = findValue(x509Values, (NSString *)kSecOIDOrganizationalUnitName);
    NSString *organizationName = findValue(x509Values, (NSString *)kSecOIDOrganizationName);
    NSString *commonName = findValue(x509Values, (NSString *)kSecOIDCommonName);

    NSString *objects[] = {
        commonName,
        organizationName,
        ouId
    };

    NSString *keys[] = {
        @"name",
        @"organization",
        @"organizationalUnit",
    };

    NSUInteger count = sizeof(objects) / sizeof(id);
    return [NSDictionary dictionaryWithObjects:objects
                                       forKeys:keys
                                         count:count];
}

NSArray *getDevelopmentTeams() {
    id objects[] = {
        (id)kSecClassCertificate,
        (id)kSecMatchLimitAll,
        @true,
        @true,
        @true
    };

    id keys[] = {
        (id)kSecClass,
        (id)kSecMatchLimit,
        (id)kSecReturnRef,
        (id)kSecMatchTrustedOnly,
        (id)kSecAttrCanSign
    };

    NSUInteger count = sizeof(objects) / sizeof(id);
    NSDictionary *query = [NSDictionary dictionaryWithObjects:objects
                                                      forKeys:keys
                                                        count:count];

    NSArray *array = NULL;
    OSStatus status = SecItemCopyMatching((CFDictionaryRef)query, (CFTypeRef *)&array);

    if (status != 0) {
        print(stderr, @"Failed to read developer identities");
        return nil;
    }

    NSMutableArray* result = [NSMutableArray arrayWithCapacity:0];

    for (id certificate in array) {
        NSDictionary *devTeam = parseDevelopmentTeam((SecCertificateRef)certificate);

        if (devTeam != nil) {
            [result addObject:devTeam];
        }
    }

    return result;
}

int main(int argc, char* argv[]) {
    [NSApplication initialize];

    NSArray *devTeams = getDevelopmentTeams();

    if (devTeams == nil)
        return 1;

    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:devTeams options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    if (error != nil) {
        print(stderr, @"Failed to stringify JSON: %@", error);
        return 2;
    }

    print(stdout, @"%@", jsonString);
    return 0;
}
