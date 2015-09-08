using System;

namespace Urchin.Client.Interfaces
{
    public interface IConfigurationStore
    {
        /// <summary>
        /// Replaces the current configuration with a new one, finds all the configuration
        /// changes, and for each change, notifies anyone that registered for these notifications.
        /// </summary>
        /// <param name="jsonText">The new configuration in JSON format</param>
        void UpdateConfiguration(string jsonText);

        /// <summary>
        /// Registers for notification when an element in the configuration changes.
        /// The callback will only be called if there is an actual change in configuration,
        /// it will not be called every time the UpdateConfiguration() method is called.
        /// </summary>
        /// <typeparam name="T">The type of data contract to deserialize from the JSON</typeparam>
        /// <param name="path">Identifies an element in the JSON configuration data. If this
        /// element changes then the change action will be executed. Think of the JSON as
        /// a tree of named objects within named objects similar to a directoty structure, then
        /// this path is sililar to a file path. Uses / separator between path elements</param>
        /// <param name="onChangeAction">This action will be executed whenever the
        /// configuration element identified by the path parameter changes.</param>
        /// <param name="defaultValue">When you call this Register method, the onChangeAction
        /// will be called immediately either with the currect configuration if it exists,
        /// or this default value if it does not</param>
        /// <returns>An IDisposable handle. Disposing of this handle will cancel the
        /// registration, and no more change events will be received. Note that if you
        /// do not keep a reference to this handle, then the garbage collector will
        /// dispose of it, and you will stop getting change notifications.</returns>
        IDisposable Register<T>(string path, Action<T> onChangeAction, T defaultValue = default(T));

        /// <summary>
        /// Retrieves the current value of an element in the configuration.
        /// This is very slow, and should only be called once at initialization.
        /// If you need to know when the configuration changes, register instead.
        /// </summary>
        /// <typeparam name="T">The type to return. If the 'path' parameter identifies
        /// a string, number or boolean in the JSON then this type should be a value 
        /// type or a string. If 'path' identifies an array this should be a list
        /// or array type, and if 'path' identifies an object in JSON then this should
        /// be a class</typeparam>
        /// <param name="path">Identifies the element in the JSON configuration
        /// data to retrieve</param>
        /// <param name="defaultValue">This value will be returned if the JSON
        /// configuration data does not contain the specified path</param>
        /// <returns>The configuration data as type T</returns>
        T Get<T>(string path, T defaultValue = default(T));
    }
}
