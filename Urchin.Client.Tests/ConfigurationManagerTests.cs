﻿using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Urchin.Client.Data;
using Urchin.Client.Sources;

namespace Urchin.Client.Tests
{
    /// <summary>
    /// Summary description for UnitTest1
    /// </summary>
    [TestClass]
    public class ConfigurationManagerTests
    {
        [TestMethod]
        public void Should_load_app_settings()
        {
            var configurationStore = new ConfigurationStore().Initialize();

            var source = new ConfigurationManagerSource(configurationStore).Initialize();
            source.LoadConfiguration();

            var value1 = configurationStore.Get<string>("appSettings/key1");
            var value2 = configurationStore.Get<string>("appSettings/key2");
            var testInt = configurationStore.Get<int>("appSettings/testInt");

            Assert.AreEqual("value1", value1);
            Assert.AreEqual("value2", value2);
            Assert.AreEqual(54, testInt);
        }
    }
}
