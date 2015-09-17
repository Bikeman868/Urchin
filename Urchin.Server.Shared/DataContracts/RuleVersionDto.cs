using System.Collections.Generic;
using Newtonsoft.Json;

namespace Urchin.Server.Shared.DataContracts
{
    public class RuleVersionDto : VersionNameDto
    {
        [JsonProperty("rules")]
        public List<RuleDto> Rules { get; set; }
    }
}
