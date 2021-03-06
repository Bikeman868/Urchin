﻿using System;
using System.Net;
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
            try
            {
                using (var webClient = new WebClient())
                {
                    content = webClient.DownloadString(_uri);
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Exception downloading Urchin configuration from '" + _uri + "'", ex);
            }
            configurationStore.UpdateConfiguration(content);
        }
    }
}
