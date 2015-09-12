using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using Common.Logging;
using Prius.Contracts.Interfaces;
using Urchin.Client.Interfaces;
using Urchin.Server.Persistence.Prius.DatabaseRecords;
using Urchin.Server.Shared.DataContracts;
using Urchin.Server.Shared.Interfaces;

namespace Urchin.Server.Persistence.Prius
{
    public class DatabasePersister : IPersister
    {
        private readonly IDisposable _configNotifier;
        private readonly ICommandFactory _commandFactory;
        private readonly IContextFactory _contextFactory;
        private readonly ILog _log;
        private readonly Shared.Interfaces.IMapper _mapper;

        private string _repositoryName;

        public DatabasePersister(
            IConfigurationStore configurationStore,
            ICommandFactory commandFactory,
            IContextFactory contextFactory,
            ILogManager logManager,
            Shared.Interfaces.IMapper mapper)
        {
            _commandFactory = commandFactory;
            _contextFactory = contextFactory;
            _log = logManager.GetLogger(GetType());
            _mapper = mapper;

            _configNotifier = configurationStore.Register("/urchin/server/persister/repository", SetRepositoryName, "Urchin");
        }

        public string CheckHealth()
        {
            var content = new StringBuilder();
            content.AppendLine("Prius persister using repository '" + _repositoryName + "'.");
            content.AppendLine("Database contains " + GetVersionNumbers().Count + " versions of the rules.");
            content.AppendLine("Database defines " + String.Join(", ", GetEnvironmentNames()) + " environments.");
            return content.ToString();
        }

        #region Default environment

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

        #endregion

        #region Versions

        public bool SupportsVersioning { get { return true; } }

        public List<int> GetVersionNumbers()
        {
            using (var context = _contextFactory.Create(_repositoryName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetVersionNumbers"))
                {
                    using (var reader = context.ExecuteReader(command))
                    {
                        var versionNumbers = new List<int>();
                        while (reader.Read())
                        {
                            versionNumbers.Add(reader.Get<int>(0));
                        }
                        return versionNumbers;
                    }
                }
            }
        }

        public void SetVersionName(int version, string newName)
        {
            using (var context = _contextFactory.Create(_repositoryName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_InsertUpdateVersion"))
                {
                    command.AddParameter("name", newName);
                    command.AddParameter("version", version);
                    context.ExecuteNonQuery(command);
                }
            }
        }

        public void DeleteVersion(int version)
        {
            using (var context = _contextFactory.Create(_repositoryName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_DeleteVersion"))
                {
                    command.AddParameter("version", version);
                    context.ExecuteNonQuery(command);
                }
            }
        }

        #endregion

        #region Rules

        public IEnumerable<string> GetRuleNames(int version)
        {
            using (var context = _contextFactory.Create(_repositoryName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetRuleNames"))
                {
                    command.AddParameter("version", version);
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

        public RuleDto GetRule(int version, string name)
        {
            using (var context = _contextFactory.Create(_repositoryName))
            {
                RuleRecord ruleRecord;
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetRule"))
                {
                    command.AddParameter("ruleName", name);
                    command.AddParameter("version", version);
                    using (var data = context.ExecuteEnumerable<RuleRecord>(command))
                    {
                        ruleRecord = data.FirstOrDefault();
                    }
                }
                if (ruleRecord == null) return null;

                var ruleDto = _mapper.Map<RuleRecord, Shared.DataContracts.RuleDto>(ruleRecord);
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetRuleVariables"))
                {
                    command.AddParameter("ruleName", name);
                    command.AddParameter("version", version);
                    using (var data = context.ExecuteEnumerable<VariableRecord>(command))
                    {
                        ruleDto.Variables = _mapper.Map<IEnumerable<VariableRecord>, List<Shared.DataContracts.VariableDeclarationDto>>(data);
                    }
                }
                return ruleDto;
            }
        }

        public IEnumerable<RuleDto> GetAllRules(int version)
        {
            return GetRuleNames(version).Select(n => GetRule(version, n)).ToList();
        }

        public void DeleteRule(int version, string name)
        {
            using (var context = _contextFactory.Create(_repositoryName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_DeleteRule"))
                {
                    command.AddParameter("ruleName", name);
                    command.AddParameter("version", version);
                    context.ExecuteNonQuery(command);
                }
            }
        }

        public void InsertOrUpdateRule(int version, RuleDto rule)
        {
            _log.Info(m => m("Updating '{0}' rule", rule.RuleName));
            using (var context = _contextFactory.Create(_repositoryName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_InsertUpdateRule"))
                {
                    command.AddParameter("ruleName", rule.RuleName);
                    command.AddParameter("version", version);
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
                    command.AddParameter("version", version);
                    context.ExecuteNonQuery(command);
                }
                if (rule.Variables != null && rule.Variables.Count > 0)
                {
                    using (var command = _commandFactory.CreateStoredProcedure("sp_InsertRuleVariable"))
                    {
                        command.AddParameter("ruleName", rule.RuleName);
                        command.AddParameter("version", version);
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

        #endregion

        #region Environments

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
                EnvironmentRecord environmentRecord;
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetEnvironment"))
                {
                    command.AddParameter("environmentName", name);
                    using (var data = context.ExecuteEnumerable<EnvironmentRecord>(command))
                    {
                        environmentRecord = data.FirstOrDefault();
                    }
                }
                if (environmentRecord == null) return null;

                var environmentDto = _mapper.Map<EnvironmentRecord, Shared.DataContracts.EnvironmentDto>(environmentRecord);

                using (var command = _commandFactory.CreateStoredProcedure("sp_GetEnvironmentMachines"))
                {
                    command.AddParameter("environmentName", name);
                    using (var reader = context.ExecuteReader(command))
                    {
                        environmentDto.Machines = new List<string>();
                        while (reader.Read())
                        {
                            environmentDto.Machines.Add(reader.Get<string>(0));
                        }
                    }
                }

                using (var command = _commandFactory.CreateStoredProcedure("sp_GetEnvironmentSecurity"))
                {
                    command.AddParameter("environmentName", name);
                    using (var security = context.ExecuteEnumerable<SecurityRuleRecord>(command))
                    {
                        environmentDto.SecurityRules = new List<SecurityRuleDto>();
                        if (security != null)
                        {
                            foreach (var rule in security)
                            {
                                environmentDto.SecurityRules.Add(new SecurityRuleDto
                                {
                                    AllowedIpStart = rule.StartIp,
                                    AllowedIpEnd = rule.EndIp
                                });
                            }
                        }
                    }
                }
                return environmentDto;
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

                using (var command = _commandFactory.CreateStoredProcedure("sp_DeleteEnvironmentSecurity"))
                {
                    command.AddParameter("environmentName", environment.EnvironmentName);
                    context.ExecuteNonQuery(command);
                }

                if (environment.SecurityRules != null && environment.SecurityRules.Count > 0)
                {
                    using (var command = _commandFactory.CreateStoredProcedure("sp_InsertEnvironmentSecurity"))
                    {
                        command.AddParameter("environmentName", environment.EnvironmentName);
                        var startIp = command.AddParameter("startIp", SqlDbType.NVarChar, ParameterDirection.Input);
                        var endIp = command.AddParameter("endIp", SqlDbType.NVarChar, ParameterDirection.Input);
                        foreach (var securityRule in environment.SecurityRules)
                        {
                            startIp.Value = securityRule.AllowedIpStart;
                            endIp.Value = securityRule.AllowedIpEnd;
                            context.ExecuteNonQuery(command);
                        }
                    }
                }

            }
        }

        #endregion

        #region Private methods

        private void SetRepositoryName(string repositoryName)
        {
            _log.Info(m => m("Using '{0}' Prius repository for Urchin configuration rules", repositoryName));
            _repositoryName = repositoryName;
        }

        #endregion
    }
}
