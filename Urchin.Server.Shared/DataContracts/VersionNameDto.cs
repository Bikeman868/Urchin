using Newtonsoft.Json;

namespace Urchin.Server.Shared.DataContracts
{
    public class VersionNameDto
    {
        [JsonProperty("RuleVersion")]
        public int Version { get; set; }

        [JsonProperty("name")]
        public string Name { get; set; }
    }

}
