using System.Collections.Generic;
using Newtonsoft.Json;

namespace Urchin.Server.Shared.DataContracts
{
    public class ConfigNodeDto
    {
        [JsonProperty("value")]
        public string Value { get; set; }

        [JsonProperty("properties")]
        public List<ConfigPropertyDto> Properties { get; set; }
    }
}
