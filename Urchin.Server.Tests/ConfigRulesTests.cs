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
            _configRules.Clear();
        }

        [TestMethod]
        public void Should_return_empty_rule_set()
        {
            var config = _configRules.GetConfig(null, "myMachine", "myApp", null);

            Assert.IsNotNull(config);
            Assert.AreEqual(0, config.Properties().Count());
        }

        [TestMethod]
        public void Should_return_simple_configuration()
        {
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
    }
}
