using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Urchin.Client.Interfaces;

namespace Urchin.Client.Data
{
    public class ConfigurationSource: IConfigurationSource
    {
        private readonly Dictionary<string, Registration>  _registrations = new Dictionary<string, Registration>();
        private string _originalJsonText;
        private ConfigNode _config = new ConfigNode();

        public IConfigurationSource Initialize()
        {
            return this;
        }

        public IDisposable Register<T>(string path, Action<T> onChangeAction)
        {
            if (onChangeAction == null) return null;

            if (string.IsNullOrEmpty(path)) path = "/";
            else
            {
                path = path.ToLower().Replace("_", "");
                if (!path.StartsWith("/")) path = "/" + path;
            }

            var key = Guid.NewGuid().ToString("N");
            var registration = new Registration<T>(this).Initialize(key, path, onChangeAction);

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
                if (!node.Children.TryGetValue(segment, out node))
                    return default(T);
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

            var changedPaths = new List<string> { "/" };
            //...
            //...
            //...

            _config = newConfig;
            _originalJsonText = jsonText;

            List<Registration> activeRegistrations;
            lock(_registrations)
                activeRegistrations = _registrations.Values.ToList();

            foreach (var registration in activeRegistrations)
                if (changedPaths.Contains(registration.Path))
                    registration.Changed();
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
                    var jobject = new JObject();
                    foreach (var child in Children.Values)
                    {
                        jobject.Add(child.Name, child.AsJson());
                    }
                    return jobject;
                }

                return JToken.Parse("null");
            }

        }

        private abstract class Registration: IDisposable
        {
            protected readonly ConfigurationSource _configurationSource;
            private string _key;
            public string Path { get; private set; }

            protected Registration(ConfigurationSource configurationSource)
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

            public Registration(ConfigurationSource configurationSource)
                : base(configurationSource)
            {
            }

            public Registration Initialize(string key, string path, Action<T> onChangeAction)
            {
                base.Initialize(key, path);
                _onChangeAction = onChangeAction;

                Changed();

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
