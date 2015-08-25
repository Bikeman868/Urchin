using Prius.Contracts.Attributes;

namespace Urchin.Server.Persistence.Prius.DatabaseRecords
{
    public class VariableRecord
    {
        [Mapping("name")]
        public string VariableName { get; set; }

        [Mapping("value")]
        public string SubstitutionValue { get; set; }
    }
}
