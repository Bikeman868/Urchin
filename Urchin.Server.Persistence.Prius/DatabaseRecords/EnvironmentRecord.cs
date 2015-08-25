using Prius.Contracts.Attributes;

namespace Urchin.Server.Persistence.Prius.DatabaseRecords
{
    public class EnvironmentRecord
    {
        [Mapping("name")]
        public string EnvironmentName { get; set; }
    }
}
