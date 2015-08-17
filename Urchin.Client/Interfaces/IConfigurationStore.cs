using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Urchin.Client.Interfaces
{
    public interface IConfigurationStore
    {
        void UpdateConfiguration(string jsonText);
        IDisposable Register<T>(string path, Action<T> onChangeAction);
        T Get<T>(string path);
    }
}
