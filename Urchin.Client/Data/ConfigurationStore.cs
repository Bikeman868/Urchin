using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Urchin.Client.Interfaces;

namespace Urchin.Client.Data
{
    /// <summary>
    /// The configuration store keeps the previous config settings,
    /// calculates a diff when new configuration is supplied, and
    /// makes notification callbacks to classes that registerd to
    /// be notified when specific elements of the config change.
    /// </summary>
    /// <remarks>
    /// This class is designed to be correct, not efficient. The
    /// assumption when building this class is that configuration changes
    /// infrequently and performance is not an issue. This class also
    /// asumes that applications will not call the Get method every
    /// time it wants to know the value of a node in codfig, but will
    /// register to receive notification of changes instead.
    /// Calling the Get method is very slow.
    /// 
    /// The Get method is thread safe, but the LoadConfiguration method
    /// is not. It is assumed that only 1 thread at a time will retrieve
    /// configuration changes and update them in this store.
    /// 
    /// When an application registers for notifications, these notification
    /// callbacks will happen on the thread that calls UpdateConfiguration()
    /// </remarks>
    public class ConfigurationStore: IConfigurationStore
    {
        private readonly Dictionary<string, Registration> _registrations = new Dictionary<string, Registration>(StringComparer.OrdinalIgnoreCase);
        private string _originalJsonText;
        private ConfigNode _config = new ConfigNode();
        private IConfigurationValidator _validator;
        private IErrorLogger _errorLogger;
        private IDecryptor _decryptor;

        public ConfigurationStore()
        {
            _validator = new DefaultValidator();
            _errorLogger = new DefaultErrorLogger();
            _decryptor = new DefaultDecryptor();
        }

        public IConfigurationStore Initialize(
            IConfigurationValidator validator = null,
            IErrorLogger errorLogger = null,
            IDecryptor decryptor = null)
        {
            _validator = validator ?? new DefaultValidator();
            _errorLogger = errorLogger ?? new DefaultErrorLogger();
            _decryptor = decryptor ?? new DefaultDecryptor();
            return this;
        }

        public IDisposable Register<T>(string path, Action<T> onChangeAction, T defaultValue)
        {
            if (onChangeAction == null) return null;

            if (string.IsNullOrWhiteSpace(path)) 
                path = string.Empty;
            else
            {
                path = path.ToLower().Replace("_", "");
                if (!path.StartsWith("/")) path = "/" + path;
            }

            if (path == "/") path = string.Empty;

            var key = Guid.NewGuid().ToString("N");
            var registration = new Registration<T>(this).Initialize(key, path, onChangeAction, defaultValue);

            try
            {
                registration.Changed();
            }
            catch (Exception ex)
            {
                LogError("Exception thrown when notifying application of configuration change in '" + registration.Path + "'. " + ex.Message);
            }

            lock(_registrations)
                _registrations.Add(key, registration);

            return registration;
        }

        public T Get<T>(string path, T defaultValue)
        {
            var node = _config;
            if (node == null)
            {
                LogError("Empty configuration, default value returned for '" + path + "'");
                return defaultValue;
            }

            var segments = path
                .Replace("_", "")
                .Split(new []{'/'}, StringSplitOptions.RemoveEmptyEntries);

            foreach (var segment in segments)
            {
                if (node.Children == null)
                    return defaultValue;
                lock (node.Children)
                {
                    if (!node.Children.TryGetValue(segment, out node))
                        return defaultValue;
                }
            }

            var json = node.AsJson();
            var jsonText = json.ToString(Formatting.None);

            var resultType = typeof (T);

            if (resultType == typeof (string))
            {
                if (json.Type == JTokenType.String)
                    return (T)(object)json.Value<string>();
                return (T) (object) jsonText;
            }

            try
            {
                if (resultType.IsValueType)
                {
                    var jValue = json as JValue;
                    if (jValue == null) return default(T);

                    if (typeof(T) == typeof(DateTime))
                        return (T)(object)DateTime.Parse(jValue.Value.ToString());

                    if (typeof(T) == typeof(TimeSpan))
                        return (T)(object)TimeSpan.Parse(jValue.Value.ToString());

                    if (typeof(T).IsEnum)
                        return (T) Enum.Parse(typeof(T), jValue.Value.ToString(), true);

                    return (T)Convert.ChangeType(jValue.Value, resultType);
                }

                return JsonConvert.DeserializeObject<T>(jsonText);
            }
            catch (Exception ex)
            {
                LogError("Exception getting configuration for '" + path +"' as " + resultType.FullName + ". " + ex.Message);
                return defaultValue;
            }
        }

        private void Deregister(string key)
        {
            lock(_registrations)
                _registrations.Remove(key);
        }

        public void UpdateConfiguration(string jsonText)
        {
            if (string.IsNullOrWhiteSpace(jsonText)) return;
            if (jsonText == _originalJsonText) return;

            JToken json;
            try
            {
                var decryptedText = _decryptor == null ? jsonText : _decryptor.Decrypt(jsonText);
                json = JToken.Parse(decryptedText);
            }
            catch (Exception ex)
            {
                LogError("Exception thrown whilst decrypting and parsing configuration: " + ex.Message);
                return;
            }

            if (_validator != null)
            {
                if (!_validator.IsValidConfiguration(json))
                {
                    LogError("Configuration failed validation and will not be updated");
                    return;
                }
            }

            ConfigNode newConfig;
            try
            {
                newConfig = new ConfigNode(json);
            }
            catch (Exception ex)
            {
                LogError(ex.Message);
                throw;
            }

            var changedPaths = new List<string>();
            AddChangedPaths(changedPaths, "", newConfig, _config);

            _config = newConfig;
            _originalJsonText = jsonText;

            List<Registration> activeRegistrations;
            lock(_registrations)
                activeRegistrations = _registrations.Values.ToList();

            var exceptions = new List<Exception>();

            foreach (var registration in activeRegistrations)
            {
                if (changedPaths.Contains(registration.Path, StringComparer.OrdinalIgnoreCase))
                {
                    try
                    {
                        registration.Changed();
                    }
                    catch (Exception ex)
                    {
                        exceptions.Add(ex);
                        LogError("Exception thrown when notifying application of configuration change in '" + registration.Path + "'. " + ex.Message);
                    }
                }
            }

            if (exceptions.Count == 1)
                throw (new Exception("One exeption was thrown whilst applying configuration changes", exceptions[0]));

            if (exceptions.Count > 1)
                throw new AggregateException("Multiple exceptions were thrown whilst applying configuration changes", exceptions);
        }

        private bool AddChangedPaths(List<string> paths, string path, ConfigNode nodeA, ConfigNode nodeB)
        {
            if (nodeA == null && nodeB == null)
                return false;

            var nodesDiffer = nodeA == null || nodeB == null;

            var childNames = new List<string>();
            if (nodeA != null && nodeA.Children != null)
                childNames.AddRange(nodeA.Children.Values.Select(n => n.Name));
            if (nodeB != null && nodeB.Children != null)
                childNames.AddRange(nodeB.Children.Values.Select(n => n.Name).Where(n => !childNames.Contains(n, StringComparer.OrdinalIgnoreCase)));

            foreach (var childName in childNames)
            {
                var childPath = path + "/" + childName;
                ConfigNode childA = null;
                ConfigNode childB = null;
                if (nodeA != null && nodeA.Children != null) nodeA.Children.TryGetValue(childName, out childA);
                if (nodeB != null && nodeB.Children != null) nodeB.Children.TryGetValue(childName, out childB);
                if ((childA == null) != (childB == null))
                {
                    AddChangedPaths(paths, childPath, childA, childB);
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

        private void LogError(string errorMessage)
        {
            if (_errorLogger != null)
                _errorLogger.LogError(errorMessage);
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
                    Children = new Dictionary<string, ConfigNode>(StringComparer.OrdinalIgnoreCase);
                    var jobject = (JObject) value;
                    foreach (var property in jobject.Properties())
                    {
                        var childName = property.Name;

                        if (Children.ContainsKey(childName))
                            throw new Exception("The Urchin configuration contains a duplicate property name '" + 
                                childName + "' for element '" + name + "'");

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

            protected Registration(
                ConfigurationStore configurationSource)
            {
                _configurationSource = configurationSource;
            }

            protected Registration Initialize(string key, string path)
            {
                _key = key;
                Path = path.ToLower();
                return this;
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
            private T _defaultValue;

            public Registration(
                ConfigurationStore configurationSource)
                : base(configurationSource)
            {
            }

            public Registration Initialize(string key, string path, Action<T> onChangeAction, T defaultValue)
            {
                _onChangeAction = onChangeAction;
                _defaultValue = defaultValue;

                return base.Initialize(key, path);
            }

            public override void Changed()
            {
                var config = _configurationSource.Get<T>(Path, _defaultValue);
                _onChangeAction(config);
            }
        }

        private class DefaultValidator: IConfigurationValidator
        {
            public bool IsValidConfiguration(JToken configuration)
            {
                if (configuration == null) return false;

                var jobject = configuration as JObject;
                return jobject != null && jobject.Properties().Any();
            }
        }

        private class DefaultErrorLogger : IErrorLogger
        {
            public void LogError(string errorMessage)
            {
                Trace.WriteLine("Urchin configuration store: " + errorMessage);
            }
        }

        private class DefaultDecryptor : IDecryptor
        {
            public string Decrypt(string original)
            {
                return original;
            }
        }
    }
}
