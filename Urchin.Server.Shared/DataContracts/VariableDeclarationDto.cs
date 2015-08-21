using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

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
