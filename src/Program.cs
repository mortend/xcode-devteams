using System;
using System.Linq;
using Newtonsoft.Json;

try
{
    var teams = new DevelopmentTeamExtractor()
                    .FindAllDevelopmentTeams()
                    .ToArray();
    var json = JsonConvert.SerializeObject(teams, Formatting.Indented);
    Console.WriteLine(json);
    return 0;
}
catch (Exception e)
{
    Console.Error.WriteLine($"Unhandled exception: {e}");
    return 1;
}
