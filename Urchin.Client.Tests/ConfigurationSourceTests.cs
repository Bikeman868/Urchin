using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Urchin.Client.Data;

namespace Urchin.Client.Tests
{
    [TestClass]
    public class ConfigurationSourceTests
    {
        [TestMethod]
        public void Should_get_empty_configuration()
        {
            var configurationSource = new ConfigurationSource().Initialize();

            var root = configurationSource.Get<string>("/");
            Assert.AreEqual("null", root);
        }

        [TestMethod]
        public void Should_get_value_configuration()
        {
            var configurationSource = new ConfigurationSource().Initialize();

            const int testValue = 76534;
            configurationSource.UpdateConfiguration(testValue.ToString());
            var root = configurationSource.Get<int>("/");

            Assert.AreEqual(testValue, root);
        }

        [TestMethod]
        public void Should_get_array_configuration()
        {
            var configurationSource = new ConfigurationSource().Initialize();

            configurationSource.UpdateConfiguration("[3,2,1]");
            var root = configurationSource.Get<int[]>("/");

            Assert.AreEqual(3, root.Length);
            Assert.AreEqual(3, root[0]);
            Assert.AreEqual(2, root[1]);
            Assert.AreEqual(1, root[2]);
        }

        [TestMethod]
        public void Should_get_object_configuration()
        {
            var configurationSource = new ConfigurationSource().Initialize();

            configurationSource.UpdateConfiguration("{field1:1,field2:2}");
            var root = configurationSource.Get<TestClassA>("/");

            Assert.IsNotNull(root);
            Assert.AreEqual(1, root.Field1);
            Assert.AreEqual(2, root.Field2);
        }

        [TestMethod]
        public void Should_parse_path()
        {
            var configurationSource = new ConfigurationSource().Initialize();

            configurationSource.UpdateConfiguration("{child1:{field1:1,field2:2},child2:{field1:99,field2:98}}");
            var root = configurationSource.Get<TestClassB>("/");
            var child1 = configurationSource.Get<TestClassA>("/child1");
            var child2 = configurationSource.Get<TestClassA>("/child2");

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
    }
}
