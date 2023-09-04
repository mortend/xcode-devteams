# xcode-devteams

CLI for information about Xcode developer teams

## Install

```sh
npm install xcode-devteams
```

## Usage

```sh
xcode-devteams
```

Running this command will print a JSON list containing information about
available Xcode developer teams, e.g.:

```json
[
  {
    "name": "Developer ID Application: Some Name (DIA8J8D8U)",
    "organization": "Some Name",
    "organizationalUnit": "DIA8J8D8U"
  },
  {
    "name": "Developer ID Application: Some Name (DIA8J8D8U)",
    "organization": "Some Name",
    "organizationalUnit": "DIA8J8D8U"
  },
  {
    "name": "iPhone Developer: Company, Inc. (58TD4L8GC)",
    "organization": "Company, Inc.",
    "organizationalUnit": "R62GJQ0H9"
  },
  {
    "name": "iPhone Distribution: Company, Inc. (R62GJQ0H9)",
    "organization": "Company, Inc.",
    "organizationalUnit": "R62GJQ0H9"
  },
  {
    "name": "Apple Development: Some Name (D952RHZGK9)",
    "organization": "Some Name",
    "organizationalUnit": "DIA8J8D8U"
  },
  {
    "name": "Apple Development: Some Name (WFNSRXRC5)",
    "organization": "Company, Inc.",
    "organizationalUnit": "R62GJQ0H9"
  }
]
```

The JSON can be consumed by other programs that might use it to generate
Xcode projects or other things.

## Building from source

> Requires macOS with `cmake` and Xcode Command Line Tools

This is a native Objective-C program that must be compiled after making changes.
Run the following command to do this:

```sh
npm run build
```

It is possible to generate a project that can be opened in Xcode using this
command:

```sh
rm -f CMakeCache.txt && cmake -GXcode .
```

## History

This functionality was originally written in C# and used as a class inside the
Uno compiler. While upgrading the Uno code base to .NET 6.0 it became difficult
to keep the functionality because of very large dependencies required to access
macOS APIs on .NET, so we ended up building a tiny executable written in
Objective-C instead :-)

Source: [DevelopmentTeam.cs](https://github.com/fuse-open/uno/blob/5ba93cc24050880b2d171b9bf96dc9744bf5e3df/src/tool/engine/Targets/Utilities/DevelopmentTeam.cs)

## License

MIT
