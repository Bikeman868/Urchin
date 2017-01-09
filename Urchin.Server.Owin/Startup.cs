using System;
using System.IO;
using System.Reflection;
using Common.Logging;
using Ioc.Modules;
using Microsoft.Owin;
using Microsoft.Owin.BuilderProperties;
using Microsoft.Practices.Unity;
using Owin;
using OwinFramework.AnalysisReporter;
using OwinFramework.Builder;
using OwinFramework.Dart;
using OwinFramework.Documenter;
using OwinFramework.ExceptionReporter;
using OwinFramework.Interfaces.Routing;
using OwinFramework.RouteVisualizer;
using Urchin.Client.Interfaces;
using Urchin.Client.Sources;
using Urchin.Server.Owin;
using OwinFramework.Interfaces.Builder;
using OwinFramework.NotFound;
using OwinFramework.OutputCache;

[assembly: OwinStartup(typeof(Startup))]

namespace Urchin.Server.Owin
{
    public class Startup
    {

        private static IDisposable _configurationFileSource;

        public void Configuration(IAppBuilder app)
        {
            try
            {
                var iocContainer = ConfigureUnity();
                _configurationFileSource = ConfigureUrchinClient(iocContainer);
                ConfigureMiddleware(app, iocContainer);

                var properties = new AppProperties(app.Properties);
                var token = properties.OnAppDisposing;
                token.Register(() =>
                {
                    _configurationFileSource.Dispose();
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
                var config = unityContainer.Resolve<IConfiguration>();
                var builder = unityContainer.Resolve<IBuilder>();

                // Define routes through the OWIN pipeline

                var configPath = new PathString("/config");
                var opsPath = new PathString("/ops");
                var uiPath = new PathString("/ui");

                builder.Register(unityContainer.Resolve<IRouter>())
                    .AddRoute("Config", c => c.Request.Path.StartsWithSegments(configPath))
                    .AddRoute("Ops", c => c.Request.Path.StartsWithSegments(opsPath))
                    .AddRoute("Ui", c => c.Request.Path.StartsWithSegments(uiPath))
                    .AddRoute("Admin", c => true)
                    .As("Router");
                
                // The logon middleware establishes the cllient ientity and must
                // run on all routes before any other middleware
                builder.Register(unityContainer.Resolve<Middleware.LogonEndpoint>())
                    .As("Logon")
                    .RunFirst()
                    .RunAfter("Exception reporter")
                    .ConfigureWith(config, "/urchin/server/logon");

                builder.Register(unityContainer.Resolve<Middleware.ConfigEndpoint>())
                    .As("Config")
                    .RunOnRoute("Config");

                builder.Register(unityContainer.Resolve<Middleware.HelloEndpoint>())
                    .As("Hello")
                    .RunOnRoute("Ops");

                builder.Register(unityContainer.Resolve<Middleware.TraceEndpoint>())
                    .As("Trace")
                    .RunOnRoute("Admin");

                builder.Register(unityContainer.Resolve<Middleware.DefaultEnvironmentEndpoint>())
                    .As("Default environment")
                    .RunOnRoute("Admin");

                builder.Register(unityContainer.Resolve<Middleware.EnvironmentsEndpoint>())
                    .As("Environments")
                    .RunOnRoute("Admin");

                builder.Register(unityContainer.Resolve<Middleware.VersionEndpoint>())
                    .As("Version")
                    .RunOnRoute("Admin");

                builder.Register(unityContainer.Resolve<Middleware.VersionsEndpoint>())
                    .As("Versions")
                    .RunOnRoute("Admin");

                builder.Register(unityContainer.Resolve<Middleware.RuleEndpoint>())
                    .As("Rule")
                    .RunOnRoute("Admin");

                builder.Register(unityContainer.Resolve<Middleware.RulesEndpoint>())
                    .As("Rules")
                    .RunOnRoute("Admin");

                builder.Register(unityContainer.Resolve<Middleware.RuleNamesEndpoint>())
                    .As("RuleNames")
                    .RunOnRoute("Admin");

                builder.Register(unityContainer.Resolve<Middleware.PostRuleEndpoint>())
                    .As("Post rule")
                    .RunOnRoute("Admin");

                builder.Register(unityContainer.Resolve<Middleware.TestEndpoint>())
                    .As("Test")
                    .RunOnRoute("Admin");

                builder.Register(unityContainer.Resolve<DartMiddleware>())
                    .As("Dart UI")
                    .RunOnRoute("UI")
                    .RunOnRoute("Ops")
                    .RunAfter("UI output cache")
                    .ConfigureWith(config, "/urchin/server/ui/dart");

                builder.Register(unityContainer.Resolve<OutputCacheMiddleware>())
                    .As("UI output cache")
                    .RunOnRoute("UI")
                    .ConfigureWith(config, "/urchin/server/ui/outputCache");

                builder.Register(unityContainer.Resolve<NotFoundMiddleware>())
                    .As("Not found")
                    .RunLast()
                    .RunOnRoute("Ops")
                    .RunOnRoute("Admin")
                    .ConfigureWith(config, "/urchin/server/notFound");

                builder.Register(unityContainer.Resolve<ExceptionReporterMiddleware>())
                    .As("Exception reporter")
                    .RunFirst()
                    .ConfigureWith(config, "/urchin/server/exceptionReporter");
             
                builder.Register(unityContainer.Resolve<DocumenterMiddleware>())
                    .As("Endpoint documenter")
                    .RunOnRoute("Ops")
                    .ConfigureWith(config, "/urchin/server/endpointDocumenter");

                builder.Register(unityContainer.Resolve<AnalysisReporterMiddleware>())
                    .As("Analysis reporter")
                    .RunOnRoute("Ops")
                    .ConfigureWith(config, "/urchin/server/analysisReporter");

                builder.Register(unityContainer.Resolve<RouteVisualizerMiddleware>())
                    .As("Route visualizer")
                    .RunOnRoute("Ops")
                    .ConfigureWith(config, "/urchin/server/visualizer");
            
                app.UseBuilder(builder);
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