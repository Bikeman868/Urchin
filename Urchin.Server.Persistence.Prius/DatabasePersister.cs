using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using Common.Logging;
using Prius.Contracts.Interfaces;
using Urchin.Client.Interfaces;
using Urchin.Server.Shared.DataContracts;
using Urchin.Server.Shared.Interfaces;

namespace Urchin.Server.Persistence.Prius
{
    public class DatabasePersister: IPersister
    {
        private readonly IDisposable _configNotifier;
        private readonly ICommandFactory _commandFactory;
        private readonly IContextFactory _contextFactory;
        private readonly ILog _log;

        private string _repositoryName;

        public DatabasePersister(
            IConfigurationStore configurationStore,
            ICommandFactory commandFactory,
            IContextFactory contextFactory,
            ILogManager logManager)
        {
            _commandFactory = commandFactory;
            _contextFactory = contextFactory;
            _log = logManager.GetLogger(GetType());

            _configNotifier = configurationStore.Register("/urchin/server/persister/repository", SetRepositoryName, "Rules");
        }

        private void SetRepositoryName(string repositoryName)
        {
            _log.Info(m => m("Using '{0}' Prius repository for Urchin configuration rules", repositoryName));
            _repositoryName = repositoryName;
        }

        public string GetDefaultEnvironment()
        {
            using (var context = _contextFactory.Create(_repositoryName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetDefaultEnvironment"))
                {
                    return context.ExecuteScalar<string>(command);
                }
            }
        }

        public void SetDefaultEnvironment(string name)
        {
            _log.Info(m => m("Changing default environment name to '{0}'", name));
            using (var context = _contextFactory.Create(_repositoryName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_UpdateDefaultEnvironment"))
                {
                    command.AddParameter("environmentName", name);
                    context.ExecuteNonQuery(command);
                }
            }
        }

        public IEnumerable<string> GetRuleNames()
        {
            using (var context = _contextFactory.Create(_repositoryName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetRuleNames"))
                {
                    using (var reader = context.ExecuteReader(command))
                    {
                        var ruleNames = new List<string>();
                        while (reader.Read())
                        {
                            ruleNames.Add(reader.Get<string>(0));
                        }
                        return ruleNames;
                    }
                }
            }
        }

        public RuleDto GetRule(string name)
        {
            using (var context = _contextFactory.Create(_repositoryName))
            {
                RuleDto rule;
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetRule"))
                {
                    command.AddParameter("ruleName", name);
                    using (var data = context.ExecuteEnumerable<RuleDto>(command))
                    {
                        rule = data.FirstOrDefault();
                    }
                }
                if (rule != null)
                {
                    using (var command = _commandFactory.CreateStoredProcedure("sp_GetRuleVariables"))
                    {
                        command.AddParameter("ruleName", name);
                        using (var data = context.ExecuteEnumerable<VariableDeclarationDto>(command))
                        {
                            rule.Variables = data.ToList();
                        }
                    }
                }
                return rule;
            }
        }

        public IEnumerable<RuleDto> GetAllRules()
        {
            return GetRuleNames().Select(GetRule).ToList();
        }

        public void DeleteRule(string name)
        {
            using (var context = _contextFactory.Create(_repositoryName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_DeleteRule"))
                {
                    command.AddParameter("ruleName", name);
                    context.ExecuteNonQuery(command);
                }
            }
        }

        public void InsertOrUpdateRule(RuleDto rule)
        {
            _log.Info(m => m("Updating '{0}' rule", rule.RuleName));
            using (var context = _contextFactory.Create(_repositoryName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_InsertUpdateRule"))
                {
                    command.AddParameter("ruleName", rule.RuleName);
                    command.AddParameter("application", rule.Application);
                    command.AddParameter("environment", rule.Environment);
                    command.AddParameter("instance", rule.Instance);
                    command.AddParameter("machine", rule.Machine);
                    command.AddParameter("config", rule.ConfigurationData);
                    context.ExecuteNonQuery(command);
                }
                using (var command = _commandFactory.CreateStoredProcedure("sp_DeleteRuleVariables"))
                {
                    command.AddParameter("ruleName", rule.RuleName);
                    context.ExecuteNonQuery(command);
                }
                if (rule.Variables != null && rule.Variables.Count > 0)
                {
                    using (var command = _commandFactory.CreateStoredProcedure("sp_InsertRuleVariable"))
                    {
                        command.AddParameter("ruleName", rule.RuleName);
                        var variableName = command.AddParameter("variableName", SqlDbType.NVarChar, ParameterDirection.Input);
                        var variableValue = command.AddParameter("variableValue", SqlDbType.NVarChar, ParameterDirection.Input);
                        foreach (var variable in rule.Variables)
                        {
                            variableName.Value = variable.VariableName;
                            variableValue.Value = variable.SubstitutionValue;
                            context.ExecuteNonQuery(command);
                        }
                    }
                }
            }
        }

        public IEnumerable<string> GetEnvironmentNames()
        {
            using (var context = _contextFactory.Create(_repositoryName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetEnvironmentNames"))
                {
                    using (var reader = context.ExecuteReader(command))
                    {
                        var environmentNames = new List<string>();
                        while (reader.Read())
                        {
                            environmentNames.Add(reader.Get<string>(0));
                        }
                        return environmentNames;
                    }
                }
            }
        }

        public EnvironmentDto GetEnvironment(string name)
        {
            using (var context = _contextFactory.Create(_repositoryName))
            {
                EnvironmentDto environment;
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetEnvironment"))
                {
                    command.AddParameter("environmentName", name);
                    using (var data = context.ExecuteEnumerable<EnvironmentDto>(command))
                    {
                        environment = data.FirstOrDefault();
                    }
                }
                if (environment != null)
                {
                    using (var command = _commandFactory.CreateStoredProcedure("sp_GetEnvironmentMachines"))
                    {
                        command.AddParameter("environmentName", name);
                        using (var reader = context.ExecuteReader(command))
                        {
                            environment.Machines = new List<string>();
                            while (reader.Read())
                            {
                                environment.Machines.Add(reader.Get<string>(0));
                            }
                        }
                    }
                }
             return environment;
           }
        }

        public IEnumerable<EnvironmentDto> GetAllEnvironments()
        {
            return GetEnvironmentNames().Select(GetEnvironment).ToList();
        }

        public void DeleteEnvironment(string name)
        {
            using (var context = _contextFactory.Create(_repositoryName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_DeleteEnvironment"))
                {
                    command.AddParameter("environmentName", name);
                    context.ExecuteNonQuery(command);
                }
            }
        }

        public void InsertOrUpdateEnvironment(EnvironmentDto environment)
        {
            _log.Info(m => m("Updating '{0}' environment", environment.EnvironmentName));
            using (var context = _contextFactory.Create(_repositoryName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_InsertUpdateEnvironment"))
                {
                    command.AddParameter("environmentName", environment.EnvironmentName);
                    context.ExecuteNonQuery(command);
                }
                using (var command = _commandFactory.CreateStoredProcedure("sp_DeleteEnvironmentMachines"))
                {
                    command.AddParameter("environmentName", environment.EnvironmentName);
                    context.ExecuteNonQuery(command);
                }
                if (environment.Machines != null && environment.Machines.Count > 0)
                {
                    using (var command = _commandFactory.CreateStoredProcedure("sp_InsertEnvironmentMachine"))
                    {
                        command.AddParameter("environmentName", environment.EnvironmentName);
                        var machineName = command.AddParameter("machineName", SqlDbType.NVarChar, ParameterDirection.Input);
                        foreach (var machine in environment.Machines)
                        {
                            machineName.Value = machine;
                            context.ExecuteNonQuery(command);
                        }
                    }
                }
            }
        }
    }
}
