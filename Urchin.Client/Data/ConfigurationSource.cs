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
        private string _originalResponse;
        private ConfigNode _config = new ConfigNode();

        public IDisposable Register<T>(string path, Action<T> onChangeAction)
        {
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

            var segments = path.ToLower().Replace("_", "").Split(new []{'/'}, StringSplitOptions.RemoveEmptyEntries);
            foreach (var segment in segments)
            {
                if (node.Children == null)
                    return default(T);
                if (!node.Children.TryGetValue(segment, out node))
                    return default(T);
            }

            var json = node.AsJson();
            var jsonText = json.ToString(Formatting.None);
            return JsonConvert.DeserializeObject<T>(jsonText);
        }

        private void Deregister(string key)
        {
            lock(_registrations)
                _registrations.Remove(key);
        }

        private void StoreNewResponse(string response)
        {
            if (response == _originalResponse) return;

            var changedPaths = new List<string>();
            var newConfig = new ConfigNode();

            _config = newConfig;
            _originalResponse = response;

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
                Children = new Dictionary<string, ConfigNode>();
            }

            public ConfigNode(string name, JToken value)
            {
                Name = name;
                Value = value;
            }

            public ConfigNode(string name)
            {
                Name = name;
                Children = new Dictionary<string, ConfigNode>();
            }

            public JToken AsJson()
            {
                if (Value != null) return Value;

                var jobject = new JObject();
                if (Children != null)
                {
                    foreach (var child in Children.Values)
                    {
                        jobject.Add(child.Name, child.AsJson());
                    }
                }
                return jobject;
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
