using Prius.Contracts.Attributes;

namespace Urchin.Server.Persistence.Prius.DatabaseRecords
{
    public class SecurityRuleRecord
    {
        [Mapping("startIp")]
        public string StartIp { get; set; }

        [Mapping("endIp")]
        public string EndIp { get; set; }
    }
}
