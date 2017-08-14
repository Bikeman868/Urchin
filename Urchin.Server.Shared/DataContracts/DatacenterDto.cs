using Newtonsoft.Json;

namespace Urchin.Server.Shared.DataContracts
{
    public class DatacenterDto
    {
        [JsonProperty("name")]
        public string  Name { get; set; }
    }
}
