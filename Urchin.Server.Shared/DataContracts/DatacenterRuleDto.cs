using Newtonsoft.Json;

namespace Urchin.Server.Shared.DataContracts
{
    public class DatacenterRuleDto
    {
        [JsonProperty("machine")]
        public string Machine { get; set; }

        [JsonProperty("application")]
        public string Application { get; set; }

        [JsonProperty("environment")]
        public string Environment { get; set; }

        [JsonProperty("instance")]
        public string Instance { get; set; }

        [JsonProperty("datacenterName")]
        public string DatacenterName { get; set; }

        [JsonIgnore]
        public string EvaluationOrder { get; set; }
    }
}
