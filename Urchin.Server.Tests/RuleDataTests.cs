using System;
using System.Collections.Generic;
using System.Linq;
using Newtonsoft.Json.Linq;
using NUnit.Framework;
using Urchin.Server.Shared.DataContracts;
using Urchin.Server.Shared.Interfaces;
using Urchin.Server.Shared.Rules;
using Urchin.Server.Shared.TypeMappings;

namespace Urchin.Server.Tests
{
    [TestFixture]
    public class RuleDataTests
    {
        private RuleData _ruleData;

        [SetUp]
        public void Initialize()
        {
            var mapper = new Mapper();
            var persister = new TestDataPersister();
            _ruleData = new RuleData(mapper, persister);
        }

        [Test]
        public void Should_return_simple_configuration()
        {
            var config = _ruleData.GetConfig(null, null, "myMachine", "myApp", null);

            Assert.IsNotNull(config);
            Assert.IsTrue(config["debug"].Value<bool>());
        }

        [Test]
        public void Should_lookup_environment_from_machine_name()
        {
            _ruleData.UnitTest_Clear();

            _ruleData.RenameVersion(null, 1, "First version");

            _ruleData.SetEnvironments(null, new List<EnvironmentDto>
            {
                new EnvironmentDto
                {
                    EnvironmentName = "Prod",
                    Machines = new List<string>{"WEB1", "WEB2"},
                    Version = 1
                },
                new EnvironmentDto
                {
                    EnvironmentName = "Test",
                    Machines = new List<string>{"TEST1", "TEST2"},
                    Version = 1
                },
                new EnvironmentDto
                {
                    EnvironmentName = "Dev",
                    Version = 1
                }

            });
            _ruleData.SetDefaultEnvironment(null, "Dev");

            _ruleData.AddRules(null, 1, new List<RuleDto>
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
                    Environment = "Dev",
                    ConfigurationData = "{host:\"localhost/mysite\",localhost:\"localhost/mysite\"}"
                }
            });


            var web1Config = _ruleData.GetConfig(null, null, "web1", "web", null);
            var web2Config = _ruleData.GetConfig(null, null, "web2", "web", null);
            var test1Config = _ruleData.GetConfig(null, null, "test1", "web", null);
            var test2Config = _ruleData.GetConfig(null, null, "test2", "web", null);
            var dev1Config = _ruleData.GetConfig(null, null, "devmachine", "web", null);
            var dev2Config = _ruleData.GetConfig(null, "prod", "devmachine", "web", null);

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

        [Test]
        public void Should_support_variable_substitution()
        {
            _ruleData.UnitTest_Clear();

            const int version = 1;

            _ruleData.RenameVersion(null, version, "First version");

            _ruleData.SetEnvironments(null, new List<EnvironmentDto>
            {
                new EnvironmentDto
                {
                    EnvironmentName = "Prod",
                    Machines = new List<string>{"WEB1", "WEB2"},
                    Version = version
                },
                new EnvironmentDto
                {
                    EnvironmentName = "Test",
                    Machines = new List<string>{"TEST1", "TEST2"},
                    Version = version
                },
                new EnvironmentDto
                {
                    EnvironmentName = "Dev",
                    Version = version
                }

            });
            _ruleData.SetDefaultEnvironment(null, "Dev");


            _ruleData.AddRules(null, version, new List<RuleDto>
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

            var configApp1Prod = _ruleData.GetConfig(null, "Prod", "WEB1", "Application1", null);
            var configApp2Prod = _ruleData.GetConfig(null, "Prod", "WEB2", "Application2", null);
            var configApp1Test = _ruleData.GetConfig(null, "Test", "WEB3", "Application1", null);
            var configApp2Test = _ruleData.GetConfig(null, "Test", "WEB4", "Application2", null);

            Assert.AreEqual("Database", configApp1Prod["log"]["method"].Value<string>());
            Assert.AreEqual("Database", configApp2Prod["log"]["method"].Value<string>());
            Assert.AreEqual("File", configApp1Test["log"]["method"].Value<string>());
            Assert.AreEqual("File", configApp2Test["log"]["method"].Value<string>());
        }

        [Test]
        public void Should_secure_restricted_environments()
        {
            _ruleData.UnitTest_Clear();
            SetupSecureEnvironments();
            _ruleData.SetDefaultEnvironment(null, "Production");

            var devClient = new ClientCredentials { IpAddress = "192.168.3.54" };
            var config1 = _ruleData.UnitTest_GetRuleSet(devClient, null);

            Assert.AreEqual(3, config1.Environments.Count);

            Assert.AreEqual("Production", config1.Environments[0].EnvironmentName);
            Assert.AreEqual("Staging", config1.Environments[1].EnvironmentName);
            Assert.AreEqual("Development", config1.Environments[2].EnvironmentName);

            Assert.AreEqual("web1", config1.Environments[0].Machines[0]);
            Assert.AreEqual("web2", config1.Environments[0].Machines[1]);
            Assert.AreEqual("web3", config1.Environments[0].Machines[2]);

            _ruleData.SetEnvironments(devClient, new List<EnvironmentDto> 
            {
                new EnvironmentDto
                {
                    EnvironmentName = "Production",
                    Machines = new List<string>{"dev1"}
                },
                new EnvironmentDto
                {
                    EnvironmentName = "Development",
                    Machines = new List<string>{"dev1", "dev2", "dev3"},
                }
            });

            var config2 = _ruleData.UnitTest_GetRuleSet(devClient, null);

            Assert.AreEqual(3, config2.Environments.Count);

            Assert.AreEqual("Production", config2.Environments[0].EnvironmentName);
            Assert.AreEqual("Staging", config2.Environments[1].EnvironmentName);
            Assert.AreEqual("Development", config2.Environments[2].EnvironmentName);

            Assert.AreEqual("web1", config2.Environments[0].Machines[0]);
            Assert.AreEqual("web2", config2.Environments[0].Machines[1]);
            Assert.AreEqual("web3", config2.Environments[0].Machines[2]);

            Assert.AreEqual("stage1", config2.Environments[1].Machines[0]);
            Assert.AreEqual("stage2", config2.Environments[1].Machines[1]);
            Assert.AreEqual("stage3", config2.Environments[1].Machines[2]);

            Assert.AreEqual("dev1", config2.Environments[2].Machines[0]);
            Assert.AreEqual("dev2", config2.Environments[2].Machines[1]);
            Assert.AreEqual("dev3", config2.Environments[2].Machines[2]);

            var stagingClient = new ClientCredentials { IpAddress = "192.168.1.2" };

            _ruleData.SetEnvironments(stagingClient, new List<EnvironmentDto> 
            {
                new EnvironmentDto
                {
                    EnvironmentName = "Production",
                    Machines = new List<string>{"dev1"}
                },
                new EnvironmentDto
                {
                    EnvironmentName = "Development",
                    Machines = new List<string>{"dev1", "dev2", "dev3"},
                }
            });

            var config3 = _ruleData.UnitTest_GetRuleSet(stagingClient, null);

            Assert.AreEqual(2, config3.Environments.Count);

            Assert.AreEqual("Production", config3.Environments[0].EnvironmentName);
            Assert.AreEqual("Development", config3.Environments[1].EnvironmentName);

            Assert.AreEqual("web1", config3.Environments[0].Machines[0]);
            Assert.AreEqual("web2", config3.Environments[0].Machines[1]);
            Assert.AreEqual("web3", config3.Environments[0].Machines[2]);

            Assert.AreEqual("dev1", config3.Environments[1].Machines[0]);
            Assert.AreEqual("dev2", config3.Environments[1].Machines[1]);
            Assert.AreEqual("dev3", config3.Environments[1].Machines[2]);

            var prodClient = new ClientCredentials { IpAddress = "192.168.0.2" };

            _ruleData.SetEnvironments(prodClient, new List<EnvironmentDto> 
            {
                new EnvironmentDto
                {
                    EnvironmentName = "Production",
                    Machines = new List<string>{"dev1"}
                },
                new EnvironmentDto
                {
                    EnvironmentName = "Development",
                    Machines = new List<string>{"dev1", "dev2", "dev3"},
                }
            });

            var config4 = _ruleData.UnitTest_GetRuleSet(prodClient, null);

            Assert.AreEqual(2, config4.Environments.Count);

            Assert.AreEqual("Production", config4.Environments[0].EnvironmentName);
            Assert.AreEqual("Development", config4.Environments[1].EnvironmentName);

            Assert.AreEqual("dev1", config4.Environments[0].Machines[0]);

            Assert.AreEqual("dev1", config4.Environments[1].Machines[0]);
            Assert.AreEqual("dev2", config4.Environments[1].Machines[1]);
            Assert.AreEqual("dev3", config4.Environments[1].Machines[2]);
        }

        [Test]
        public void Should_not_retrieve_config_from_restricted_environment()
        {
            _ruleData.UnitTest_Clear();
            SetupSecureEnvironments();

            var productionClient = new ClientCredentials { IpAddress = "192.168.0.32" };
            var stagingClient = new ClientCredentials { IpAddress = "192.168.1.99" };
            var developmentClient = new ClientCredentials { IpAddress = "192.168.2.161" };

            var web1Production = _ruleData.GetConfig(productionClient, "", "web1", "myApp", "");
            var web1Staging = _ruleData.GetConfig(stagingClient, "", "web1", "myApp", "");
            var web1Development = _ruleData.GetConfig(developmentClient, "", "web1", "myApp", "");

            var stage2Production = _ruleData.GetConfig(productionClient, "", "stage2", "myApp", "");
            var stage2Staging = _ruleData.GetConfig(stagingClient, "", "stage2", "myApp", "");
            var stage2Development = _ruleData.GetConfig(developmentClient, "", "stage2", "myApp", "");

            var dev1Production = _ruleData.GetConfig(productionClient, "", "dev1", "myApp", "");
            var dev1Staging = _ruleData.GetConfig(stagingClient, "", "dev1", "myApp", "");
            var dev1Development = _ruleData.GetConfig(developmentClient, "", "dev1", "myApp", "");

            const string emptyConfig = "{}";

            Assert.IsTrue(web1Production.ToString().IndexOf("web1.mysite.com") > 0);
            Assert.AreEqual(emptyConfig, web1Staging.ToString());
            Assert.AreEqual(emptyConfig, web1Development.ToString());

            Assert.IsTrue(stage2Production.ToString().IndexOf("stage2.mysite.local") > 0);
            Assert.IsTrue(stage2Staging.ToString().IndexOf("stage2.mysite.local") > 0);
            Assert.AreEqual(emptyConfig, stage2Development.ToString());

            Assert.IsTrue(dev1Production.ToString().IndexOf("localhost/mysite") > 0);
            Assert.IsTrue(dev1Staging.ToString().IndexOf("localhost/mysite") > 0);
            Assert.IsTrue(dev1Development.ToString().IndexOf("localhost/mysite") > 0);
        }

        [Test]
        public void Should_not_retrieve_rules_from_restricted_environment()
        {
            _ruleData.UnitTest_Clear();
            SetupSecureEnvironments();

            var productionClient = new ClientCredentials { IpAddress = "192.168.0.32" };
            var stagingClient = new ClientCredentials { IpAddress = "192.168.1.99" };
            var developmentClient = new ClientCredentials { IpAddress = "192.168.2.161" };

            var productionRules = _ruleData.UnitTest_GetRuleSet(productionClient, null).RuleVersion;
            var stagingRules = _ruleData.UnitTest_GetRuleSet(stagingClient, null).RuleVersion;
            var developmentRules = _ruleData.UnitTest_GetRuleSet(developmentClient, null).RuleVersion;

            Assert.AreEqual(3, productionRules.Rules.Count);
            Assert.AreEqual(2, stagingRules.Rules.Count);
            Assert.AreEqual(1, developmentRules.Rules.Count);

            Assert.AreEqual("Production Environment", productionRules.Rules[0].RuleName);
            Assert.AreEqual("Staging Environment", productionRules.Rules[1].RuleName);
            Assert.AreEqual("Development Environment", productionRules.Rules[2].RuleName);

            Assert.AreEqual("Staging Environment", stagingRules.Rules[0].RuleName);
            Assert.AreEqual("Development Environment", stagingRules.Rules[1].RuleName);

            Assert.AreEqual("Development Environment", developmentRules.Rules[0].RuleName);
        }

        [Test]
        public void Should_not_add_rules_for_restricted_environments()
        {
            _ruleData.UnitTest_Clear();
            SetupSecureEnvironments();

            var productionClient = new ClientCredentials { IpAddress = "192.168.0.32" };
            var developmentClient = new ClientCredentials { IpAddress = "192.168.2.161" };

            var draftRules = _ruleData.UnitTest_GetRuleSet(null, null);
            var version = draftRules.RuleVersion.Version;

            var exception = false;
            try
            {
                _ruleData.AddRules(
                    developmentClient, 
                    version,
                    new List<RuleDto>
                    {
                        new RuleDto
                        {
                            RuleName = "Test Rule",
                            Environment = "Production",
                            Application = "MyNewApp"
                        }
                    });

            }
            catch
            {
                exception = true;
            }

            var newRules = _ruleData.UnitTest_GetRuleSet(productionClient, null).RuleVersion.Rules;

            Assert.IsTrue(exception);
            Assert.AreEqual(3, newRules.Count);
            Assert.IsFalse(newRules.Any(r => r.RuleName == "Test Rule"));
        }

        [Test]
        public void Should_not_add_rules_for_restricted_machines()
        {
            _ruleData.UnitTest_Clear();
            SetupSecureEnvironments();

            var productionClient = new ClientCredentials { IpAddress = "192.168.0.32" };
            var developmentClient = new ClientCredentials { IpAddress = "192.168.2.161" };

            var draftRules = _ruleData.UnitTest_GetRuleSet(null, null);
            var version = draftRules.RuleVersion.Version;

            var exception = false;
            try
            {
                _ruleData.AddRules(
                    developmentClient, 
                    version,
                    new List<RuleDto>
                        {
                            new RuleDto
                            {
                                RuleName = "Test Rule",
                                Machine = "web2",
                                Application = "MyNewApp"
                            }
                        });

            }
            catch
            {
                exception = true;
            }

            var newRules = _ruleData.UnitTest_GetRuleSet(productionClient, null).RuleVersion.Rules;

            Assert.IsTrue(exception);
            Assert.AreEqual(3, newRules.Count);
            Assert.IsFalse(newRules.Any(r => r.RuleName == "Test Rule"));
        }

        [Test]
        public void Should_not_update_rules_for_restricted_environments()
        {
            _ruleData.UnitTest_Clear();
            SetupSecureEnvironments();

            var productionClient = new ClientCredentials { IpAddress = "192.168.0.32" };
            var developmentClient = new ClientCredentials { IpAddress = "192.168.2.161" };

            var draftRules = _ruleData.UnitTest_GetRuleSet(null, null);
            var version = draftRules.RuleVersion.Version;

            var exception = false;
            try
            {
                _ruleData.UpdateRule(
                    developmentClient, 
                    version,
                    "Production Environment",
                    new RuleDto
                    {
                        RuleName = "Production Environment",
                        Environment = "Development",
                        Application = "MyNewApp"
                    });
            }
            catch
            {
                exception = true;
            }

            var newRules = _ruleData.UnitTest_GetRuleSet(productionClient, null).RuleVersion.Rules;

            Assert.IsTrue(exception);
            Assert.AreEqual(3, newRules.Count);
            Assert.AreEqual("Production Environment", newRules[0].RuleName);
            Assert.AreEqual("Production", newRules[0].Environment);
        }

        private void SetupSecureEnvironments()
        {
            const int version = 1;

            _ruleData.SetEnvironments(null, new List<EnvironmentDto>
                {
                    new EnvironmentDto
                    {
                        EnvironmentName = "Production",
                        Version = version,
                        Machines = new List<string>{"web1", "web2", "web3"},
                        SecurityRules = new List<SecurityRuleDto>
                        {
                            new SecurityRuleDto{AllowedIpStart = "192.168.0.1", AllowedIpEnd = "192.168.0.255"}
                        }
                    },
                    new EnvironmentDto
                    {
                        EnvironmentName = "Staging",
                        Version = version,
                        Machines = new List<string>{"stage1", "stage2", "stage3"},
                        SecurityRules = new List<SecurityRuleDto>
                        {
                            new SecurityRuleDto{AllowedIpStart = "192.168.0.1", AllowedIpEnd = "192.168.1.255"}
                        }
                    },
                    new EnvironmentDto
                    {
                        EnvironmentName = "Development",
                        Version = version
                    }
                });

            _ruleData.AddRules(null, version, new List<RuleDto>
            {
                new RuleDto
                {
                    RuleName = "Production Environment",
                    Environment = "Production",
                    ConfigurationData = "{host:\"www.mysite.com\",localhost:\"($machine$).mysite.com\"}"
                },
                new RuleDto
                {
                    RuleName = "Staging Environment",
                    Environment = "Staging",
                    ConfigurationData = "{host:\"staging.mysite.local\",localhost:\"($machine$).mysite.local\"}"
                },
                new RuleDto
                {
                    RuleName = "Development Environment",
                    Environment = "Development",
                    ConfigurationData = "{host:\"localhost/mysite\",localhost:\"localhost/mysite\"}"
                }
            });

            _ruleData.SetDefaultEnvironment(null, "Development");
        }

        private class ClientCredentials : IClientCredentials
        {
            public string IpAddress { get; set; }
            public bool IsAdministrator { get; set; }
            public bool IsLoggedOn { get; set; }
            public string Username { get; set; }
        }

    }
}
