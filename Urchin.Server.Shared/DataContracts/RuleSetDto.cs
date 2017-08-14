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

        [JsonProperty("applications")]
        public List<ApplicationDto> Applications { get; set; }

        [JsonProperty("datacenters")]
        public List<ApplicationDto> Datacenters { get; set; }

        [JsonProperty("rules")]
        public RuleVersionDto RuleVersion { get; set; }

        [JsonProperty("datacenterRules")]
        public List<DatacenterRuleDto> DatacenterRules { get; set; }
    }
}
