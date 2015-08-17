using System;

namespace Urchin.Client.Interfaces
{
    public interface IConfigurationStore
    {
        void UpdateConfiguration(string jsonText);
        IDisposable Register<T>(string path, Action<T> onChangeAction, T defaultValue = default(T));
        T Get<T>(string path, T defaultValue = default(T));
    }
}
