﻿using System;
using System.Diagnostics;
using System.IO;
using System.Threading;
using Urchin.Client.Interfaces;

namespace Urchin.Client.Sources
{
    public abstract class Source: IDisposable
    {
        private readonly IConfigurationStore _configurationStore;

        private TimeSpan _pollInterval;
        private Thread _thread;
        private bool _isPolling;

        protected Source(IConfigurationStore configurationStore)
        {
            _configurationStore = configurationStore;
        }

        protected IDisposable Initialize(TimeSpan pollInterval)
        {
            _pollInterval = pollInterval;

            Poll(_configurationStore);

            _thread = new Thread(ThresdEntry);
            _thread.IsBackground = true;

            _isPolling = true;
            _thread.Start();

            return this;
        }

        public void Dispose()
        {
            _isPolling = false;

            if (_thread != null)
            {
                if (!_thread.Join(TimeSpan.FromSeconds(10)))
                    _thread.Abort();
                _thread = null;
            }
        }

        private void ThresdEntry()
        {
            var sleepSeconds = _pollInterval.TotalSeconds / 10;
            if (sleepSeconds > 1) sleepSeconds = 1;
            var sleepTime = TimeSpan.FromSeconds(sleepSeconds);

            var nextPoll = DateTime.UtcNow + _pollInterval;

            while (_isPolling)
            {
                try
                {
                    Thread.Sleep(sleepTime);
                    if (DateTime.UtcNow >= nextPoll)
                    {
                        nextPoll = DateTime.UtcNow + _pollInterval;
                        Poll(_configurationStore);
                    }
                }
                catch (ThreadAbortException)
                {
                    return;
                }
                catch (Exception ex)
                {
                    Trace.WriteLine("Exception polling Urchin source: " + ex.Message);
                }
            }
        }

        protected abstract void Poll(IConfigurationStore configurationStore);
    }
}
