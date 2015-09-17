using Newtonsoft.Json;

namespace Urchin.Server.Shared.DataContracts
{
    public class VariableDeclarationDto
    {
        [JsonProperty("name")]
        public string VariableName { get; set; }

        [JsonProperty("value")]
        public string SubstitutionValue { get; set; }
    }
}
