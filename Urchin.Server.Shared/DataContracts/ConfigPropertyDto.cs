using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
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
