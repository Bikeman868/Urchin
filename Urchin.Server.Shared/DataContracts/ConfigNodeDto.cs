using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
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
