using System;
using System.IO;
using System.Net;
using System.Threading;
using Urchin.Client.Interfaces;

namespace Urchin.Client.Sources
{
    /// <summary>
    /// Polls a URI for application configuration changes
    /// </summary>
    public class UriSource: Source
    {
        private Uri _uri;

        public UriSource(IConfigurationStore configurationStore)
            : base(configurationStore)
        {
        }

        public IDisposable Initialize(Uri uri, TimeSpan pollInterval)
        {
            _uri = uri;
            return base.Initialize(pollInterval);
        }

        protected override void Poll(IConfigurationStore configurationStore)
        {
            string content;
            using (var webClient = new WebClient())
            {
                content = webClient.DownloadString(_uri);
            }
            configurationStore.UpdateConfiguration(content);
        }
    }
}
