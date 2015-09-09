using System.Collections.Generic;
using Newtonsoft.Json;

namespace Urchin.Server.Shared.DataContracts
{
    public class RuleVersionDto
    {
        [JsonProperty("version")]
        public int Version { get; set; }

        [JsonProperty("rules")]
        public List<RuleDto> Rules { get; set; }
    }
}
