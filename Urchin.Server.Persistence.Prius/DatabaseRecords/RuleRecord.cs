using Prius.Contracts.Attributes;

namespace Urchin.Server.Persistence.Prius.DatabaseRecords
{
    public class RuleRecord
    {
        [Mapping("name")]
        public string RuleName { get; set; }

        [Mapping("machine")]
        public string Machine { get; set; }

        [Mapping("application")]
        public string Application { get; set; }

        [Mapping("environment")]
        public string Environment { get; set; }

        [Mapping("instance")]
        public string Instance { get; set; }

        [Mapping("config")]
        public string ConfigurationData { get; set; }
    }
}
