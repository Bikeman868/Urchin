using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Urchin.Server.Shared.DataContracts;

namespace Urchin.Server.Shared.Interfaces
{
    public interface IPersister
    {
        string GetDefaultEnvironment();
        void SetDefaultEnvironment(string name);

        IEnumerable<string> GetRuleNames();
        RuleDto GetRule(string name);
        IEnumerable<RuleDto> GetAllRules();
        void DeleteRule(string name);
        void InsertOrUpdateRule(RuleDto rule);

        IEnumerable<string> GetEnvironmentNames();
        EnvironmentDto GetEnvironment(string name);
        IEnumerable<EnvironmentDto> GetAllEnvironments();
        void DeleteEnvironment(string name);
        void InsertOrUpdateEnvironment(RuleDto rule);
    }
}
