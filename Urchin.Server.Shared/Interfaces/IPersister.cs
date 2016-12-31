using System;
using System.Collections.Generic;
using Urchin.Server.Shared.DataContracts;

namespace Urchin.Server.Shared.Interfaces
{
    public interface IPersister
    {
        string CheckHealth();

        string GetDefaultEnvironment();
        void SetDefaultEnvironment(string name);

        List<int> GetVersionNumbers();
        void SetVersionName(int version, string newName);
        string GetVersionName(int version);
        void DeleteVersion(int version);

        IEnumerable<string> GetRuleNames(int version);
        RuleDto GetRule(int version, string name);
        IEnumerable<RuleDto> GetAllRules(int version);
        void DeleteRule(int version, string name);
        void InsertOrUpdateRule(int version, RuleDto rule);

        IEnumerable<string> GetEnvironmentNames();
        EnvironmentDto GetEnvironment(string name);
        IEnumerable<EnvironmentDto> GetAllEnvironments();
        void DeleteEnvironment(string name);
        void InsertOrUpdateEnvironment(EnvironmentDto environment);
    }
}
