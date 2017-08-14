using Newtonsoft.Json;

namespace Urchin.Server.Shared.DataContracts
{
    public class ApplicationDto
    {
        [JsonProperty("name")]
        public string  Name { get; set; }
    }
}
