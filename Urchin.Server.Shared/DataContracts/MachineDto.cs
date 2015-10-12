using Newtonsoft.Json;

namespace Urchin.Server.Shared.DataContracts
{
    public class MachineDto
    {
        [JsonProperty("name")]
        public string  Name { get; set; }
    }
}
