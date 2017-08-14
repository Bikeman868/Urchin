using Newtonsoft.Json;

namespace Urchin.Server.Shared.DataContracts
{
    public class PostResponseDto
    {
        [JsonProperty("success")]
        public bool Success { get; set; }

        [JsonProperty("error")]
        public string ErrorMessage { get; set; }

        [JsonProperty("id")]
        public string Id { get; set; }
    }
}
