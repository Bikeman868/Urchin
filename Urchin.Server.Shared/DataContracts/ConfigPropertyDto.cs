using Newtonsoft.Json;

namespace Urchin.Server.Shared.DataContracts
{
    public class ConfigPropertyDto
    {
        [JsonProperty("name")]
        public string PropertyName { get; set; }

        [JsonProperty("value")]
        public ConfigNodeDto PropertyValue { get; set; }
    }
}
