using System;

namespace Urchin.Client.Interfaces
{
    public interface IConfigurationStore
    {
        /// <summary>
        /// Defines the required behavior of the configuration store. If you do not initialize it then
        /// it will have a default behavior.
        /// </summary>
        /// <param name="validator">Specifies how configuration data should be validated prior
        /// to applying it to the application. If you pass null then the default behavior is
        /// to check that the configuration is valid JSON containing an object with at least
        /// one property</param>
        /// <param name="errorLogger">Specifies the error logging behaviour. If you pass null
        /// then the default behaviour is to write error messages to System.Diagnostics.Trace</param>
        /// <param name="decryptor">Specified how to decrypt the received configuration file
        /// before parsing as JSON. This allows configuration files to be stored or transmitted
        /// in an encrypted form and decrypted by the Urchin client. If you do not provide an
        /// implementation then the Urchin client will assume that the configuration files
        /// are stored/transmitted in plain text</param>
        /// <returns>A store of configuration data. Application modules can register to be
        /// notified when specific areas of the configuration data are changed.</returns>
        IConfigurationStore Initialize(
            IConfigurationValidator validator = null, 
            IErrorLogger errorLogger = null,
            IDecryptor decryptor = null);

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
        /// a tree of named objects within named objects similar to a directory structure, then
        /// this path is similar to a file path. Uses / separator between path elements</param>
        /// <param name="onChangeAction">This action will be executed whenever the
        /// configuration element identified by the path parameter changes.</param>
        /// <param name="defaultValue">When you call this Register method, the onChangeAction
        /// will be called immediately either with the correct configuration if it exists,
        /// or this default value if it does not</param>
        /// <returns>An IDisposable handle. Disposing of this handle will cancel the
        /// registration, and no more change events will be received. Note that if you
        /// do not keep a reference to this handle, then the garbage collector will
        /// dispose of it, and you will stop getting change notifications.</returns>
        IDisposable Register<T>(string path, Action<T> onChangeAction, T defaultValue);

        /// <summary>
        /// Registers for notification when an element in the configuration changes.
        /// The callback will only be called if there is an actual change in configuration,
        /// it will not be called when the UpdateConfiguration() method is called unless there
        /// is a change below the specified path.
        /// </summary>
        /// <typeparam name="T">The type of data contract to deserialize from the JSON</typeparam>
        /// <param name="path">Identifies an element in the JSON configuration data. If this
        /// element changes then the change action will be executed. Think of the JSON as
        /// a tree of named objects within named objects similar to a directory structure, then
        /// this path is similar to a file path. Uses / separator between path elements</param>
        /// <param name="onChangeAction">This action will be executed whenever the
        /// configuration element identified by the path parameter changes. Note in this
        /// overload the onChangeAction will not be called if the new configuration can
        /// not be deserialized as type T. In these cases an error will be logged and the
        /// configuration will not be updated</param>
        /// <remarks>If the configuration file does not contain a valid configuration for this path
        /// then an exception will be thrown. If you do not want this behaviour then you should
        /// use the overload that takes a default value parameter. If there is a change to the
        /// configuration and the new configuration is invalid then the error will be
        /// logged but the onChangeAction will not be called.</remarks>
        IDisposable Register<T>(string path, Action<T> onChangeAction);

        /// <summary>
        /// Retrieves the current value of an element in the configuration.
        /// This is very slow, and should only be called once at initialization.
        /// If you need to know when the configuration changes, DO NOT POLL, register 
        /// for changes instead.
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
        T Get<T>(string path, T defaultValue);

        /// <summary>
        /// Retrieves the current value of an element in the configuration.
        /// This is very slow, and should only be called once at initialization.
        /// If you need to know when the configuration changes, DO NOT POLL, register 
        /// for changes instead.
        /// </summary>
        /// <typeparam name="T">The type to return. If the 'path' parameter identifies
        /// a string, number or boolean in the JSON then this type should be a value 
        /// type or a string. If 'path' identifies an array this should be a list
        /// or array type, and if 'path' identifies an object in JSON then this should
        /// be a class</typeparam>
        /// <param name="path">Identifies the element in the JSON configuration
        /// data to retrieve</param>
        /// <returns>The configuration data as type T</returns>
        /// <remarks>If the configuration file does not contain a valid configuration
        /// for this path, then an exception will be thrown. If you do not want this
        /// behaviour then you should use the overload that takes a default value
        /// parameter</remarks>
        T Get<T>(string path);
    }
}
