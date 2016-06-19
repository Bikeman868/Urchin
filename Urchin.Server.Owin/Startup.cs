using System;
using System.IO;
using System.Reflection;
using Common.Logging;
using Ioc.Modules;
using Microsoft.Owin;
using Microsoft.Owin.BuilderProperties;
using Microsoft.Practices.Unity;
using Owin;
using Urchin.Client.Interfaces;
using Urchin.Client.Sources;
using Urchin.Server.Owin;

[assembly: OwinStartup(typeof(Startup))]

namespace Urchin.Server.Owin
{
    public class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            try
            {
                var iocContainer = ConfigureUnity();
                var configSource = ConfigureUrchinClient(iocContainer);
                ConfigureMiddleware(app, iocContainer);

                var properties = new AppProperties(app.Properties);
                var token = properties.OnAppDisposing;
                token.Register(() =>
                {
                    configSource.Dispose();
                    iocContainer.Dispose();
                });
            }
            catch (Exception ex)
            {
                ConfigureFailedMiddleware(app, ex);
            }
        }

        private UnityContainer ConfigureUnity()
        {
            var unityContainer = new UnityContainer();
            unityContainer.RegisterInstance<Shared.Interfaces.IFactory>(new UnityFactory(unityContainer));

            // Register IoC dependencies for all dependent packages
            // Explicitly load is assemblies packages first so that
            var packageLocator = new PackageLocator()
                .Add(typeof(IConfigurationStore).Assembly)
                .Add(Assembly.GetExecutingAssembly())
                .ProbeBinFolderAssemblies();
            Ioc.Modules.Unity.Registrar.Register(packageLocator, unityContainer);

            return unityContainer;
        }

        private class UnityFactory : Shared.Interfaces.IFactory
        {
            private readonly UnityContainer _unity;

            public UnityFactory(UnityContainer unity)
            {
                _unity = unity;
            }

            public T Create<T>()
            {
                return _unity.Resolve<T>();
            }
        }

        /// <summary>
        /// Configures OWIN middleware handlers. Note that the handlers run in the 
        /// order they are are listed here, so put the most frequently called ones
        /// at the begining of the list
        /// </summary>
        private void ConfigureMiddleware(IAppBuilder app, UnityContainer unityContainer)
        {
            try
            {
                // This must be the first endpoint because it establishes client credentials
                app.Use(unityContainer.Resolve<Middleware.LogonEndpoint>().Invoke);

                // These endpoints are called by production servers
                app.Use(unityContainer.Resolve<Middleware.ConfigEndpoint>().Invoke);
                app.Use(unityContainer.Resolve<Middleware.HelloEndpoint>().Invoke);

                // These endpoints are for administration only and have very low throughput
                app.Use(unityContainer.Resolve<Middleware.UiEndpoint>().Invoke);
                app.Use(unityContainer.Resolve<Middleware.TraceEndpoint>().Invoke);
                app.Use(unityContainer.Resolve<Middleware.DefaultEnvironmentEndpoint>().Invoke);
                app.Use(unityContainer.Resolve<Middleware.EnvironmentsEndpoint>().Invoke);
                app.Use(unityContainer.Resolve<Middleware.VersionEndpoint>().Invoke);
                app.Use(unityContainer.Resolve<Middleware.VersionsEndpoint>().Invoke);
                app.Use(unityContainer.Resolve<Middleware.RuleEndpoint>().Invoke);
                app.Use(unityContainer.Resolve<Middleware.RulesEndpoint>().Invoke);
                app.Use(unityContainer.Resolve<Middleware.RuleNamesEndpoint>().Invoke);
                app.Use(unityContainer.Resolve<Middleware.PostRuleEndpoint>().Invoke);
                app.Use(unityContainer.Resolve<Middleware.TestEndpoint>().Invoke);

                // This must be the last endpoint because it always returns a 404
                app.Use(unityContainer.Resolve<Middleware.NotFoundMiddleware>().Invoke);
            }
            catch (Exception ex)
            {
                var log = LogManager.GetLogger(GetType());
                var innerExceptions = string.Empty;
                var innerException = ex.InnerException;
                while (innerException != null)
                {
                    innerExceptions += innerException.Message + "\r\n";
                    innerException = innerException.InnerException;
                }
                log.FatalFormat("Failed to construct OWIN handler chain.\r\n{0}\r\n{1}\r\n{2}", ex.Message, ex.StackTrace, innerExceptions);
                throw;
            }
        }

        private void ConfigureFailedMiddleware(IAppBuilder app, Exception exception)
        {
            app.Use(new Middleware.FailedSetupMiddleware(exception).Invoke);
        }

        /// <summary>
        /// Configures Urchin client to read ita configuration from a file in the
        /// parent of the bin foldar (the main folder of the site). This file
        /// will be used to configure the server and also to configure other
        /// modules that use Urchin (like Prius for example).
        /// Note that you should configure IIS to not serve this file.
        /// </summary>
        private IDisposable ConfigureUrchinClient(UnityContainer unityContainer)
        {
            var fileName = "Urchin.json";
            var thisAssembly = Assembly.GetExecutingAssembly();
            var codeBaseUri = new Uri(thisAssembly.CodeBase);
            if (codeBaseUri.IsFile)
            {
                var binFolderPath = Path.GetDirectoryName(codeBaseUri.LocalPath);
                if (binFolderPath != null)
                {
                    var siteFolderPath = Directory.GetParent(binFolderPath).FullName;
                    fileName = Path.Combine(siteFolderPath, fileName);
                }
            }
            var fileInfo = new FileInfo(fileName);

            var configurationSource = unityContainer.Resolve<FileSource>().Initialize(fileInfo, TimeSpan.FromSeconds(10));

            return configurationSource;
        }
    }
}