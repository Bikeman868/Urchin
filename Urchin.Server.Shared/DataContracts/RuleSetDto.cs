using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace Urchin.Server.Shared.DataContracts
{
    public class RuleSetDto
    {
        [JsonProperty("defaultEnvironment")]
        public string DefaultEnvironmentName { get; set; }

        [JsonProperty("environments")]
        public List<EnvironmentDto> Environments { get; set; }

        [JsonProperty("rules")]
        public List<RuleDto> Rules { get; set; }
    }
}
