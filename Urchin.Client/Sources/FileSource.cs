using System;
using System.IO;
using System.Threading;
using Urchin.Client.Interfaces;

namespace Urchin.Client.Sources
{
    /// <summary>
    /// Polls a configuration file and updates application configuration whenever the file changes
    /// </summary>
    public class FileSource: Source
    {
        private FileInfo _file;

        public FileSource(IConfigurationStore configurationStore)
            : base(configurationStore)
        {
        }

        public IDisposable Initialize(FileInfo file, TimeSpan pollInterval)
        {
            _file = file;
            return base.Initialize(pollInterval);
        }

        protected override void Poll(IConfigurationStore configurationStore)
        {
            string content;
            using (var stream = _file.Open(FileMode.Open, FileAccess.Read, FileShare.Read))
            {
                using (var reader = new StreamReader(stream))
                {
                    content = reader.ReadToEnd();
                }
            }
            configurationStore.UpdateConfiguration(content);
        }
    }
}
