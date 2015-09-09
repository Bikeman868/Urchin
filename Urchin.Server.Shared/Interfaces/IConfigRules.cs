using Newtonsoft.Json.Linq;
using System.Collections.Generic;
using Urchin.Server.Shared.DataContracts;

namespace Urchin.Server.Shared.Interfaces
{
    public interface IConfigRules
    {
        /// <summary>
        /// Gets the configuration of an application using the current configuration version
        /// for the environment in which the application is executing.
        /// </summary>
        JObject GetCurrentConfig(IClientCredentials clientCredentials, string environment, string machine, string application, string instance);

        /// <summary>
        /// Gets the configuration of an application using the current configuration version
        /// for the environment in which the application is executing, and returns information
        /// about how that configuration was arrived at.
        /// </summary>
        JObject TraceCurrentConfig(IClientCredentials clientCredentials, string environment, string machine, string application, string instance);

        /// <summary>
        /// Tests a version of the rules by supplying a query, and returning the config
        /// that would be returned if these rules were saved.
        /// </summary>
        JObject TestConfig(RuleSetDto ruleSet, string environment, string machine, string application, string instance);

        /// <summary>
        /// Returns a specific version of the rules. If no version number is passed, then
        /// the most recent version that is not active in any environment is returned. If 
        /// necessary a new version is created from a copy of the most recent rules. 
        /// </summary>
        RuleSetDto GetRuleSet(IClientCredentials clientCredentials, int? version = null);

        /// <summary>
        /// Deletes everything, only used in unit tests
        /// </summary>
        void Clear(IClientCredentials clientCredentials);

        /// <summary>
        /// Overwrites a version of the rules, or creates a new version based on the 
        /// rules passed.
        /// </summary>
        int SetRuleSet(IClientCredentials clientCredentials, RuleSetDto rules, bool asNewVersion);

        /// <summary>
        /// Sets the environment that applies to all unknwn machines
        /// </summary>
        void SetDefaultEnvironment(IClientCredentials clientCredentials, string environmentName);

        /// <summary>
        /// Overwrites all the environments with new data
        /// </summary>
        void SetEnvironments(IClientCredentials clientCredentials, List<EnvironmentDto> environments);

        /// <summary>
        /// Adds a rule to an existing version of the rules
        /// </summary>
        void AddRules(IClientCredentials clientCredentials, int version, List<RuleDto> newRules);

        /// <summary>
        /// Replaces a rule in an existing version of the rules
        /// </summary>
        void UpdateRule(IClientCredentials clientCredentials, int version, string oldName, RuleDto rules);

        /// <summary>
        /// Deletes a rule from an existing version of the rules
        /// </summary>
        void DeleteRule(IClientCredentials clientCredentials, int version, string name);
    }
}
