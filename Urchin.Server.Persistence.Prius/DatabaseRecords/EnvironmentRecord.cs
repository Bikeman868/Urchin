using Prius.Contracts.Attributes;

namespace Urchin.Server.Persistence.Prius.DatabaseRecords
{
    public class EnvironmentRecord
    {
        [Mapping("id")]
        public long Id { get; set; }
        
        [Mapping("name")]
        public string EnvironmentName { get; set; }

        [Mapping("version")]
        public int Version { get; set; }
    }
}
