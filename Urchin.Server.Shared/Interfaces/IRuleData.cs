using Newtonsoft.Json.Linq;
using System.Collections.Generic;
using Urchin.Server.Shared.DataContracts;

namespace Urchin.Server.Shared.Interfaces
{
    public interface IRuleData
    {
        #region Querying for application config

        /// <summary>
        /// Gets the configuration of an application using the current configuration RuleVersion
        /// for the environment in which the application is executing.
        /// </summary>
        JObject GetConfig(IClientCredentials clientCredentials, string environment, string machine, string application, string instance);

        /// <summary>
        /// Gets the configuration of an application using the current configuration RuleVersion
        /// for the environment in which the application is executing, and returns information
        /// about how that configuration was arrived at.
        /// </summary>
        JObject TraceConfig(IClientCredentials clientCredentials, string environment, string machine, string application, string instance);

        /// <summary>
        /// Tests a version of the rules by supplying a query, and returning the config
        /// that would be returned if these rules were saved.
        /// </summary>
        JObject TestConfig(IClientCredentials clientCredentials, int version, string environment, string machine, string application, string instance);

        #endregion

        #region Environment administration

        /// <summary>
        /// Retrieves the default environment for machines that are not specifically configured
        /// </summary>
        string GetDefaultEnvironment();

        /// <summary>
        /// Retrieves a list of the environments
        /// </summary>
        List<EnvironmentDto> GetEnvironments(IClientCredentials clientCredentials);

        /// <summary>
        /// Sets the environment that applies to all unknwn machines
        /// </summary>
        void SetDefaultEnvironment(IClientCredentials clientCredentials, string environmentName);

        /// <summary>
        /// Overwrites all the environments with new data
        /// </summary>
        void SetEnvironments(IClientCredentials clientCredentials, List<EnvironmentDto> environments);

        /// <summary>
        /// Changes the RuleVersion of rules that will be applied in an environment
        /// </summary>
        void SetEnvironmentVersion(IClientCredentials clientCredentials, string environmentName, int version);

        #endregion

        #region Rule administration

        /// <summary>
        /// Retrieves a specific version of the rules, or the draft version if no version number
        /// is passed in.
        /// </summary>
        RuleVersionDto GetRuleVersion(IClientCredentials clientCredentials, int? version = null);

        /// <summary>
        /// Adds a rule to an existing RuleVersion of the rules
        /// </summary>
        void AddRules(IClientCredentials clientCredentials, int version, List<RuleDto> newRules);

        /// <summary>
        /// Replaces a rule in an existing RuleVersion of the rules
        /// </summary>
        void UpdateRule(IClientCredentials clientCredentials, int version, string oldName, RuleDto rules);

        /// <summary>
        /// Deletes a rule from an existing RuleVersion of the rules
        /// </summary>
        void DeleteRule(IClientCredentials clientCredentials, int version, string name);

        #endregion

        #region Version administration

        /// <summary>
        /// Changes the name of a version
        /// </summary>
        void RenameVersion(IClientCredentials clientCredentials, int version, string newName);

        /// <summary>
        /// Returns a list of the versions and their names
        /// </summary>
        List<VersionNameDto> GetVersions();

        /// <summary>
        /// Deletes a versionn of the rules
        /// </summary>
        void DeleteVersion(IClientCredentials clientCredentials, int version);

        /// <summary>
        /// Deletes all versions older than the oldest RuleVersion assigned to an environment
        /// </summary>
        void DeleteOldVersions();

        #endregion
    }
}
