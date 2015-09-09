using System.Collections.Generic;
using Newtonsoft.Json;

namespace Urchin.Server.Shared.DataContracts
{
    public class RuleDto
    {
        [JsonProperty("name")]
        public string RuleName { get; set; }

        [JsonProperty("machine")]
        public string Machine { get; set; }

        [JsonProperty("application")]
        public string Application { get; set; }

        [JsonProperty("environment")]
        public string Environment { get; set; }

        [JsonProperty("instance")]
        public string Instance { get; set; }

        [JsonProperty("variables")]
        public List<VariableDeclarationDto> Variables { get; set; }

        [JsonProperty("config")]
        public string ConfigurationData { get; set; }

        [JsonIgnore]
        public string EvaluationOrder { get; set; }
    }
}
