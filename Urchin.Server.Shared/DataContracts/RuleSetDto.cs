using System.Collections.Generic;
using Newtonsoft.Json;

namespace Urchin.Server.Shared.DataContracts
{
    public class RuleSetDto
    {
        [JsonProperty("defaultEnvironment")]
        public string DefaultEnvironmentName { get; set; }

        [JsonProperty("environments")]
        public List<EnvironmentDto> Environments { get; set; }

        [JsonProperty("rules")]
        public RuleVersionDto RuleVersion { get; set; }
    }
}
