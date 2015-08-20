using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

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
        public JToken ConfigurationData { get; set; }
    }
}
