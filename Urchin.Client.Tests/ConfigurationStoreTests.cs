﻿using System;
using System.Collections.Generic;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Newtonsoft.Json.Linq;
using Urchin.Client.Data;
using Urchin.Client.Interfaces;

namespace Urchin.Client.Tests
{
    [TestClass]
    public class ConfigurationStoreTests
    {
        [TestMethod]
        public void Should_get_empty_configuration()
        {
            var configurationStore = new ConfigurationStore().Initialize();

            var root = configurationStore.Get<string>("/");
            Assert.AreEqual("null", root);
        }

        [TestMethod]
        public void Should_get_value_configuration()
        {
            var configurationStore = new ConfigurationStore().Initialize();

            const int testValue = 76534;
            configurationStore.UpdateConfiguration(testValue.ToString());
            var root = configurationStore.Get<int>("/");

            Assert.AreEqual(testValue, root);
        }

        [TestMethod]
        public void Should_get_array_configuration()
        {
            var configurationStore = new ConfigurationStore().Initialize();

            configurationStore.UpdateConfiguration("[3,2,1]");
            var root = configurationStore.Get<int[]>("/");

            Assert.AreEqual(3, root.Length);
            Assert.AreEqual(3, root[0]);
            Assert.AreEqual(2, root[1]);
            Assert.AreEqual(1, root[2]);
        }

        [TestMethod]
        public void Should_get_object_configuration()
        {
            var configurationStore = new ConfigurationStore().Initialize();

            configurationStore.UpdateConfiguration("{field1:1,field2:2}");
            var root = configurationStore.Get<TestClassA>("/");

            Assert.IsNotNull(root);
            Assert.AreEqual(1, root.Field1);
            Assert.AreEqual(2, root.Field2);
        }

        [TestMethod]
        public void Should_ignore_leading_slash()
        {
            var configurationStore = new ConfigurationStore().Initialize();

            configurationStore.UpdateConfiguration("{field1:1,field2:2}");
            var root = configurationStore.Get<TestClassA>("/");
            var field1 = configurationStore.Get<int>("/field1");

            Assert.IsNotNull(root);
            Assert.AreEqual(1, root.Field1);
            Assert.AreEqual(2, root.Field2);
            Assert.AreEqual(1, field1);

            root = configurationStore.Get<TestClassA>("");
            field1 = configurationStore.Get<int>("field1");

            Assert.IsNotNull(root);
            Assert.AreEqual(1, root.Field1);
            Assert.AreEqual(2, root.Field2);
            Assert.AreEqual(1, field1);
        }

        [TestMethod]
        public void Should_parse_path()
        {
            var configurationStore = new ConfigurationStore().Initialize();

            configurationStore.UpdateConfiguration("{child1:{field1:1,field2:2},child2:{field1:99,field2:98}}");
            var root = configurationStore.Get<TestClassB>("/");
            var child1 = configurationStore.Get<TestClassA>("/child1");
            var child2 = configurationStore.Get<TestClassA>("/child2");

            Assert.IsNotNull(root);
            Assert.IsNotNull(root.Child1);
            Assert.IsNotNull(root.Child2);
            Assert.AreEqual(1, root.Child1.Field1);
            Assert.AreEqual(2, root.Child1.Field2);
            Assert.AreEqual(99, root.Child2.Field1);
            Assert.AreEqual(98, root.Child2.Field2);

            Assert.IsNotNull(child1);
            Assert.AreEqual(1, child1.Field1);
            Assert.AreEqual(2, child1.Field2);

            Assert.IsNotNull(child2);
            Assert.AreEqual(99, child2.Field1);
            Assert.AreEqual(98, child2.Field2);
        }

        [TestMethod]
        public void Should_notify_only_changed_values()
        {
            var configurationStore = new ConfigurationStore().Initialize();

            const string originalConfig = "{child1:{field1:1,field2:2},child2:{field1:99,field2:98}}";
            const string updatedConfig =  "{child1:{field1:3,field2:2},child2:{field1:99,field2:98}}";

            configurationStore.UpdateConfiguration(originalConfig);

            var rootChanged = false;
            var child1Changed = false;
            var child2Changed = false;
            var child1Field1Changed = false;
            var child1Field2Changed = false;
            var child2Field1Changed = false;
            var child2Field2Changed = false;

            configurationStore.Register("", (string json) => rootChanged = true);
            configurationStore.Register("/child1", (TestClassA child) => child1Changed = true);
            configurationStore.Register("/child1/field1", (int v) => child1Field1Changed = true);
            configurationStore.Register("/child1/field2", (int v) => child1Field2Changed = true);
            configurationStore.Register("/child2", (TestClassA child) => child2Changed = true);
            configurationStore.Register("/child2/field1", (int v) => child2Field1Changed = true);
            configurationStore.Register("/child2/field2", (int v) => child2Field2Changed = true);

            Assert.IsTrue(rootChanged);
            Assert.IsTrue(child1Changed);
            Assert.IsTrue(child2Changed);
            Assert.IsTrue(child1Field1Changed);
            Assert.IsTrue(child1Field2Changed);
            Assert.IsTrue(child2Field1Changed);
            Assert.IsTrue(child2Field2Changed);

            rootChanged = false;
            child1Changed = false;
            child2Changed = false;
            child1Field1Changed = false;
            child1Field2Changed = false;
            child2Field1Changed = false;
            child2Field2Changed = false;

            configurationStore.UpdateConfiguration(updatedConfig);

            Assert.IsTrue(rootChanged);
            Assert.IsTrue(child1Changed);
            Assert.IsFalse(child2Changed);
            Assert.IsTrue(child1Field1Changed);
            Assert.IsFalse(child1Field2Changed);
            Assert.IsFalse(child2Field1Changed);
            Assert.IsFalse(child2Field2Changed);
        }

        [TestMethod]
        public void Should_pass_new_value_on_change_notification()
        {
            var configurationStore = new ConfigurationStore().Initialize();

            const string originalConfig = "{child1:{field1:1,field2:2},child2:{field1:99,field2:98}}";
            const string updatedConfig = "{child1:{field1:3,field2:2},child2:{field1:99,field2:98}}";

            configurationStore.UpdateConfiguration(originalConfig);

            var child1Field1Value = 0;

            configurationStore.Register("/child1/field1", (int v) => child1Field1Value = v);

            Assert.AreEqual(1, child1Field1Value);

            configurationStore.UpdateConfiguration(updatedConfig);

            Assert.AreEqual(3, child1Field1Value);
        }

        [TestMethod]
        public void Should_not_notify_after_deregistration()
        {
            var configurationStore = new ConfigurationStore().Initialize();

            const string config1 = "{child1:{field1:1,field2:2},child2:{field1:99,field2:98}}";
            const string config2 = "{child1:{field1:3,field2:2},child2:{field1:99,field2:98}}";

            configurationStore.UpdateConfiguration(config1);

            var child1Field1Value = 0;

            var registration = configurationStore.Register("/child1/field1", (int v) => child1Field1Value = v);

            Assert.AreEqual(1, child1Field1Value);

            configurationStore.UpdateConfiguration(config2);

            Assert.AreEqual(3, child1Field1Value);
            
            registration.Dispose();
            configurationStore.UpdateConfiguration(config1);

            Assert.AreEqual(3, child1Field1Value);
            Assert.AreEqual(1, configurationStore.Get<int>("/child1/field1"));
        }

        [TestMethod]
        public void Should_work_with_any_json_type()
        {
            var configurationStore = new ConfigurationStore().Initialize();

            const string config = "{children:[{field1:1,field2:2},{field1:99,field2:98}],doubleValue:1.56,stringValue:'my string',dateTimeValue:'2015-08-17T15:45:12'}";

            configurationStore.UpdateConfiguration(config);
            var root = configurationStore.Get<TestClassC>("");

            Assert.IsNotNull(root);
            Assert.IsNotNull(root.Children);
            Assert.AreEqual(1.56, root.DoubleValue, 0.001);
            Assert.AreEqual("my string", root.StringValue);
            Assert.AreEqual(DateTime.Parse("2015-08-17T15:45:12"), root.DateTimeValue);
            Assert.AreEqual(2, root.Children.Count);
            Assert.IsNotNull(root.Children[0]);
            Assert.IsNotNull(root.Children[1]);
            Assert.AreEqual(1, root.Children[0].Field1);
            Assert.AreEqual(2, root.Children[0].Field2);
            Assert.AreEqual(99, root.Children[1].Field1);
            Assert.AreEqual(98, root.Children[1].Field2);
        }

        [TestMethod]
        public void Should_not_apply_invalid_configuration()
        {
            var validator = new Validator {IsValid = true};
            var configurationStore = new ConfigurationStore().Initialize(validator);

            const string originalConfig = "{child1:{field1:1,field2:2},child2:{field1:99,field2:98}}";
            const string updatedConfig = "{child1:{field1:3,field2:2},child2:{field1:99,field2:98}}";

            configurationStore.UpdateConfiguration(originalConfig);

            var child1Field1Value = 0;
            configurationStore.Register("/child1/field1", (int v) => child1Field1Value = v);

            Assert.AreEqual(1, child1Field1Value);

            validator.IsValid = false;
            configurationStore.UpdateConfiguration(updatedConfig);

            Assert.AreEqual(1, child1Field1Value);
        }

        [TestMethod]
        public void Should_log_configuration_errors()
        {
            var validator = new Validator { IsValid = true };
            var errorLogger = new ErrorLogger();
            var configurationStore = new ConfigurationStore().Initialize(validator, errorLogger);

            const string config = "{child1:{field1:1,field2:2},child2:{field1:99,field2:98}}";
            configurationStore.UpdateConfiguration(config);

            Assert.AreEqual(0, errorLogger.Errors.Count);

            var value = configurationStore.Get("child1/field1", new TestClassA{Field1 = 45});

            Assert.AreEqual(1, errorLogger.Errors.Count);
            Assert.AreEqual(45, value.Field1);
        }

        [TestMethod]
        public void Should_return_defaults_for_missing_values()
        {
            var validator = new Validator { IsValid = true };
            var errorLogger = new ErrorLogger();
            var configurationStore = new ConfigurationStore().Initialize(validator, errorLogger);

            const string config = "{child1:{field1:1,field2:2},child2:{field1:99,field2:98}}";
            configurationStore.UpdateConfiguration(config);

            Assert.AreEqual(0, errorLogger.Errors.Count);

            var value = configurationStore.Get("child1/missingField", new TestClassA { Field1 = 45 });

            Assert.AreEqual(0, errorLogger.Errors.Count);
            Assert.AreEqual(45, value.Field1);
        }

        public class Validator : IConfigurationValidator
        {
            public bool IsValid { get; set; }

            public bool IsValidConfiguration(JToken configuration)
            {
                return IsValid;
            }
        }

        public class ErrorLogger : IErrorLogger
        {
            public List<string> Errors = new List<string>();

            public void LogError(string errorMessage)
            {
                Errors.Add(errorMessage);
            }
        }

        public class TestClassA
        {
            public int Field1 { get; set; }
            public int Field2 { get; set; }
        }

        public class TestClassB
        {
            public TestClassA Child1 { get; set; }
            public TestClassA Child2 { get; set; }
        }

        public class TestClassC
        {
            public double DoubleValue { get; set; }
            public DateTime DateTimeValue { get; set; }
            public string StringValue { get; set; }
            public List<TestClassA> Children { get; set; }
        }
    }
}
