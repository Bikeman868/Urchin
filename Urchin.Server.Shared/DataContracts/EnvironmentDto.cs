using System.Collections.Generic;
using Newtonsoft.Json;

namespace Urchin.Server.Shared.DataContracts
{
    public class EnvironmentDto
    {
        [JsonProperty("name")]
        public string EnvironmentName { get; set; }

        [JsonProperty("RuleVersion")]
        public int Version { get; set; }

        [JsonProperty("machines")]
        public List<string> Machines { get; set; }

        [JsonProperty("securityRules")]
        public List<SecurityRuleDto> SecurityRules { get; set; }
    }
}
