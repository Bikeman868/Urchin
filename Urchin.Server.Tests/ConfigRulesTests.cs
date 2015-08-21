using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Newtonsoft.Json.Linq;
using Urchin.Server.Shared.DataContracts;
using Urchin.Server.Shared.Rules;
using Urchin.Server.Shared.TypeMappings;

namespace Urchin.Server.Tests
{
    [TestClass]
    public class ConfigRulesTests
    {
        private ConfigRules _configRules;

        [TestInitialize]
        public void Initialize()
        {
            var mapper = new Mapper();
            _configRules = new ConfigRules(mapper);
        }

        [TestMethod]
        public void Should_return_empty_rule_set()
        {
            _configRules.Clear();
            var config = _configRules.GetConfig(null, "myMachine", "myApp", null);

            Assert.IsNotNull(config);
            Assert.AreEqual(0, config.Properties().Count());
        }

        [TestMethod]
        public void Should_return_simple_configuration()
        {
            _configRules.Clear();
            _configRules.SetDefaultEnvironment("Integration");
            _configRules.AddRules(new List<RuleDto>
            {
                new RuleDto
                {
                    RuleName = "root",
                    ConfigurationData = "{test:876}"
                }
            });

            var config = _configRules.GetConfig(null, "myMachine", "myApp", null);

            Assert.IsNotNull(config);
            Assert.AreEqual(876, config["test"].Value<int>());
        }

        [TestMethod]
        public void Should_lookup_environment_from_machine_name()
        {
            _configRules.Clear();
            _configRules.SetDefaultEnvironment("Development");
            _configRules.SetEnvironments(new List<EnvironmentDto>
            {
                new EnvironmentDto
                {
                    EnvironmentName = "Prod",
                    Machines = new List<string>{"WEB1", "WEB2"}
                },
                new EnvironmentDto
                {
                    EnvironmentName = "Test",
                    Machines = new List<string>{"TEST1", "TEST2"}
                }
            });
            _configRules.AddRules(new List<RuleDto>
            {
                new RuleDto
                {
                    RuleName = "Prod Environment",
                    Environment = "Prod",
                    ConfigurationData = "{host:\"www.mysite.com\",localhost:\"($machine$).mysite.com\"}"
                },
                new RuleDto
                {
                    RuleName = "Test Environment",
                    Environment = "Test",
                    ConfigurationData = "{host:\"test.mysite.local\",localhost:\"($machine$).mysite.local\"}"
                },
                new RuleDto
                {
                    RuleName = "Development Environment",
                    Environment = "Development",
                    ConfigurationData = "{host:\"localhost/mysite\",localhost:\"localhost/mysite\"}"
                }
            });


            var web1Config = _configRules.GetConfig(null, "web1", "web", null);
            var web2Config = _configRules.GetConfig(null, "web2", "web", null);
            var test1Config = _configRules.GetConfig(null, "test1", "web", null);
            var test2Config = _configRules.GetConfig(null, "test2", "web", null);
            var dev1Config = _configRules.GetConfig(null, "devmachine", "web", null);
            var dev2Config = _configRules.GetConfig("prod", "devmachine", "web", null);

            Assert.IsNotNull(web1Config);
            Assert.IsNotNull(web2Config);
            Assert.IsNotNull(test1Config);
            Assert.IsNotNull(test2Config);
            Assert.IsNotNull(dev1Config);
            Assert.IsNotNull(dev2Config);

            Assert.AreEqual("www.mysite.com", web1Config["host"].Value<string>());
            Assert.AreEqual("www.mysite.com", web2Config["host"].Value<string>());
            Assert.AreEqual("test.mysite.local", test1Config["host"].Value<string>());
            Assert.AreEqual("test.mysite.local", test2Config["host"].Value<string>());
            Assert.AreEqual("localhost/mysite", dev1Config["host"].Value<string>());
            Assert.AreEqual("www.mysite.com", dev2Config["host"].Value<string>());

            Assert.AreEqual("web1.mysite.com", web1Config["localhost"].Value<string>());
            Assert.AreEqual("web2.mysite.com", web2Config["localhost"].Value<string>());
            Assert.AreEqual("test1.mysite.local", test1Config["localhost"].Value<string>());
            Assert.AreEqual("localhost/mysite", dev1Config["localhost"].Value<string>());
            Assert.AreEqual("devmachine.mysite.com", dev2Config["localhost"].Value<string>());
        }

        [TestMethod]
        public void Should_support_variable_substitution()
        {
            _configRules.Clear();
            _configRules.SetDefaultEnvironment("Development");

            _configRules.AddRules(new List<RuleDto>
            {
                new RuleDto
                {
                    RuleName = "Prod Environment",
                    Environment = "Prod",
                    Variables = new List<VariableDeclarationDto>()
                    {
                        new VariableDeclarationDto { VariableName = "logMethod", SubstitutionValue = "Database" },
                        new VariableDeclarationDto { VariableName = "logFolder", SubstitutionValue = "L:/Logs" }
                    }
                },
                new RuleDto
                {
                    RuleName = "Test Environment",
                    Environment = "Test",
                    Variables = new List<VariableDeclarationDto>()
                    {
                        new VariableDeclarationDto { VariableName = "logMethod", SubstitutionValue = "File" },
                        new VariableDeclarationDto { VariableName = "logFolder", SubstitutionValue = "C:/Logs" }
                    }
                },
                new RuleDto
                {
                    RuleName = "Application 1",
                    Application = "Application1",
                    ConfigurationData = "{log:{method:\"($logMethod$)\",filePath:\"($logFolder$)/Application1\"}}"
                }
                ,
                new RuleDto
                {
                    RuleName = "Application 2",
                    Application = "Application2",
                    ConfigurationData = "{log:{method:\"($logMethod$)\",filePath:\"($logFolder$)/Application2\"}}"
                }
            });

            var configApp1Prod = _configRules.GetConfig("Prod", "WEB1", "Application1", null);
            var configApp2Prod = _configRules.GetConfig("Prod", "WEB2", "Application2", null);
            var configApp1Test = _configRules.GetConfig("Test", "WEB3", "Application1", null);
            var configApp2Test = _configRules.GetConfig("Test", "WEB4", "Application2", null);

            Assert.AreEqual("Database", configApp1Prod["log"]["method"].Value<string>());
            Assert.AreEqual("Database", configApp2Prod["log"]["method"].Value<string>());
            Assert.AreEqual("File", configApp1Test["log"]["method"].Value<string>());
            Assert.AreEqual("File", configApp2Test["log"]["method"].Value<string>());
        }

    }
}
