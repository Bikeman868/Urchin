using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Urchin.Client.Interfaces;

namespace Urchin.Client.Data
{
    /// <summary>
    /// 
    /// </summary>
    /// <remarks>
    /// This class is designed to be correct, not efficient. Ths
    /// assumption when building this class is that configuration changes
    /// infrequently and performance is not an issue. This class also
    /// asumes that applications will not call the Get method every
    /// time it wants to know the value of a node in codfig, but will
    /// register to receive notification of changes instead.
    /// Calling the Get method is very slow.
    /// 
    /// The Get method is thread safe, but the UpdateConfiguration method
    /// is not. It is assumed that only 1 thread at a time will retrieve
    /// configuration changes and update them in this store.
    /// 
    /// When an application registers for notifications, these notification
    /// callbacks will happen on the thread that calls UpdateConfiguration()
    /// </remarks>
    public class ConfigurationStore: IConfigurationStore
    {
        private readonly Dictionary<string, Registration>  _registrations = new Dictionary<string, Registration>();
        private string _originalJsonText;
        private ConfigNode _config = new ConfigNode();

        public IConfigurationStore Initialize()
        {
            return this;
        }

        public IDisposable Register<T>(string path, Action<T> onChangeAction)
        {
            if (onChangeAction == null) return null;

            if (string.IsNullOrWhiteSpace(path)) 
                path = "";
            else
            {
                path = path.ToLower().Replace("_", "");
                if (!path.StartsWith("/")) path = "/" + path;
            }

            var key = Guid.NewGuid().ToString("N");
            var registration = new Registration<T>(this).Initialize(key, path, onChangeAction);
            registration.Changed();

            lock(_registrations)
                _registrations.Add(key, registration);

            return registration;
        }

        public T Get<T>(string path)
        {
            var node = _config;
            if (node == null) return default(T);

            var segments = path
                .ToLower()
                .Replace("_", "")
                .Split(new []{'/'}, StringSplitOptions.RemoveEmptyEntries);

            foreach (var segment in segments)
            {
                if (node.Children == null)
                    return default(T);
                lock (node.Children)
                {
                    if (!node.Children.TryGetValue(segment, out node))
                        return default(T);
                }
            }

            var json = node.AsJson();
            var jsonText = json.ToString(Formatting.None);

            var resultType = typeof (T);

            if (resultType == typeof (string)) 
                return (T)(object)jsonText;

            if (resultType.IsValueType)
            {
                var jValue = json as JValue;
                if (jValue == null) return default(T);
                return (T)Convert.ChangeType(jValue.Value, resultType);
            }

            return JsonConvert.DeserializeObject<T>(jsonText);
        }

        private void Deregister(string key)
        {
            lock(_registrations)
                _registrations.Remove(key);
        }

        public void UpdateConfiguration(string jsonText)
        {
            if (jsonText == _originalJsonText) return;

            var json = JToken.Parse(jsonText);
            var newConfig = new ConfigNode(json);

            var changedPaths = new List<string>();
            AddChangedPaths(changedPaths, "", newConfig, _config);

            _config = newConfig;
            _originalJsonText = jsonText;

            List<Registration> activeRegistrations;
            lock(_registrations)
                activeRegistrations = _registrations.Values.ToList();

            foreach (var registration in activeRegistrations)
                if (changedPaths.Contains(registration.Path))
                    registration.Changed();
        }

        private bool AddChangedPaths(List<string> paths, string path, ConfigNode nodeA, ConfigNode nodeB)
        {
            var nodesDiffer = false;

            var childNames = new List<string>();
            if (nodeA.Children != null)
                childNames.AddRange(nodeA.Children.Values.Select(n => n.Name));
            if (nodeB.Children != null)
                childNames.AddRange(nodeB.Children.Values.Select(n => n.Name).Where(n => !childNames.Contains(n)));

            foreach (var childName in childNames)
            {
                var childPath = path + "/" + childName;
                var childA = nodeA.Children == null ? null : nodeA.Children[childName];
                var childB = nodeB.Children == null ? null : nodeB.Children[childName];
                if ((childA == null) != (childB == null))
                {
                    paths.Add(childPath);
                    nodesDiffer = true;
                }
                else
                {
                    var childrenDiffer = AddChangedPaths(paths, childPath, childA, childB);
                    if (childrenDiffer) nodesDiffer = true;
                }
            }

            if (!nodesDiffer)
            {
                if ((nodeA.Children == null) != (nodeB.Children == null)) nodesDiffer = true;
                if ((nodeA.Value == null) != (nodeB.Value == null)) nodesDiffer = true;
            }

            if (!nodesDiffer && nodeA.Value != null && nodeB.Value != null)
            {
                nodesDiffer = nodeA.Value.ToString(Formatting.None) != nodeB.Value.ToString(Formatting.None);
            }

            if (nodesDiffer) paths.Add(path);
            return nodesDiffer;
        }

        private class ConfigNode
        {
            public string Name { get; private set; }
            public JToken Value { get; private set; }
            public Dictionary<string, ConfigNode> Children { get; private set; }

            public ConfigNode()
            {
                Name = "";
            }

            public ConfigNode(JToken value)
                : this("", value)
            {
            }

            private ConfigNode(string name, JToken value)
            {
                Name = name;
                if (value.Type == JTokenType.Object)
                {
                    Children = new Dictionary<string, ConfigNode>();
                    var jobject = (JObject) value;
                    foreach (var property in jobject.Properties())
                    {
                        var childName = property.Name.ToLower();
                        Children.Add(childName, new ConfigNode(childName, property.Value));
                    }
                }
                else if (value.Type != JTokenType.Null)
                    Value = value;
            }

            public JToken AsJson()
            {
                if (Value != null) return Value;

                if (Children != null)
                {
                    lock (Children)
                    {
                        var jobject = new JObject();
                        foreach (var child in Children.Values)
                        {
                            jobject.Add(child.Name, child.AsJson());
                        }
                        return jobject;
                    }
                }

                return JToken.Parse("null");
            }

        }

        private abstract class Registration: IDisposable
        {
            protected readonly ConfigurationStore _configurationSource;
            private string _key;
            public string Path { get; private set; }

            protected Registration(ConfigurationStore configurationSource)
            {
                _configurationSource = configurationSource;
            }

            protected void Initialize(string key, string path)
            {
                _key = key;
                Path = path.ToLower();
            }

            public void Dispose()
            {
                _configurationSource.Deregister(_key);
            }

            public abstract void Changed();
        }

        private class Registration<T> : Registration
        {
            private Action<T> _onChangeAction;

            public Registration(ConfigurationStore configurationSource)
                : base(configurationSource)
            {
            }

            public Registration Initialize(string key, string path, Action<T> onChangeAction)
            {
                base.Initialize(key, path);
                _onChangeAction = onChangeAction;
                return this;
            }

            public override void Changed()
            {
                var config = _configurationSource.Get<T>(Path);
                _onChangeAction(config);
            }
        }
    }
}
