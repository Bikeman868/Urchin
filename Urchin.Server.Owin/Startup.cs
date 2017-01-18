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
using OwinFramework.Interfaces.Builder;
using OwinFramework.Interfaces.Utility;
using OwinFramework.Less;
using OwinFramework.NotFound;
using OwinFramework.OutputCache;
using OwinFramework.StaticFiles;
using OwinFramework.Versioning;
using Urchin.Client.Interfaces;
using Urchin.Client.Sources;
using Urchin.Server.Owin;

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

            // Register IoC dependencies for all dependent packages.
            // Explicitly load this assemblies packages first so that
            // these IoC mappings override those found through probing
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
        private void ConfigureMiddleware(IAppBuilder app, IUnityContainer unityContainer)
        {
            try
            {
                var config = unityContainer.Resolve<IConfiguration>();
                var builder = unityContainer.Resolve<IBuilder>();

                // Define routes through the OWIN pipeline

                //var configPath = new PathString("/config");
                //var opsPath = new PathString("/ops");
                //var uiPath = new PathString("/ui");

                //builder.Register(unityContainer.Resolve<IRouter>())
                //    .AddRoute("Config", c => c.Request.Path.StartsWithSegments(configPath))
                //    .AddRoute("Ops", c => c.Request.Path.StartsWithSegments(opsPath))
                //    .AddRoute("Ui", c => c.Request.Path.StartsWithSegments(uiPath))
                //    .AddRoute("Admin", c => true)
                //    .As("Router");
                
                /******************************************************************************
                 * Middleware that must run first
                 *****************************************************************************/

                builder.Register(unityContainer.Resolve<ExceptionReporterMiddleware>())
                    .As("Exception reporter")
                    .RunFirst()
                    .ConfigureWith(config, "/urchin/server/exceptionReporter");

                builder.Register(unityContainer.Resolve<Middleware.LogonEndpoint>())
                    .As("Logon")
                    .RunFirst()
                    .RunAfter("Exception reporter")
                    .ConfigureWith(config, "/urchin/server/logon");

                builder.Register(unityContainer.Resolve<OutputCacheMiddleware>())
                    .As("Output cache")
                    .RunFirst()
                    .RunAfter("Logon")
                    .ConfigureWith(config, "/urchin/server/ui/outputCache");

                /******************************************************************************
                 * The Config middleware is called very frequently by all applications in
                 * the entire enterprise and must be very low latency
                 *****************************************************************************/

                builder.Register(unityContainer.Resolve<Middleware.ConfigEndpoint>())
                    //.RunOnRoute("Config")
                    .As("Config");

                /******************************************************************************
                 * Middleware to help the ops team to troubleshoot issues
                 *****************************************************************************/

                builder.Register(unityContainer.Resolve<Middleware.HelloEndpoint>())
                    //.RunOnRoute("Ops")
                    .As("Hello");

                builder.Register(unityContainer.Resolve<Middleware.TraceEndpoint>())
                    //.RunOnRoute("Admin")
                    .As("Trace");

                builder.Register(unityContainer.Resolve<DocumenterMiddleware>())
                    //.RunOnRoute("Ops")
                    .As("Endpoint documenter")
                    .ConfigureWith(config, "/urchin/server/endpointDocumenter");

                builder.Register(unityContainer.Resolve<AnalysisReporterMiddleware>())
                    //.RunOnRoute("Ops")
                    .As("Analysis reporter")
                    .ConfigureWith(config, "/urchin/server/analysisReporter");

                builder.Register(unityContainer.Resolve<RouteVisualizerMiddleware>())
                    //.RunOnRoute("Ops")
                    .As("Route visualizer")
                    .ConfigureWith(config, "/urchin/server/visualizer");

                /******************************************************************************
                 * Middleware to configure Urchin
                 *****************************************************************************/

                builder.Register(unityContainer.Resolve<Middleware.DefaultEnvironmentEndpoint>())
                    //.RunOnRoute("Admin")
                    .As("Default environment");

                builder.Register(unityContainer.Resolve<Middleware.EnvironmentsEndpoint>())
                    //.RunOnRoute("Admin")
                    .As("Environments");

                builder.Register(unityContainer.Resolve<Middleware.VersionEndpoint>())
                    //.RunOnRoute("Admin")
                    .As("Version");

                builder.Register(unityContainer.Resolve<Middleware.VersionsEndpoint>())
                    //.RunOnRoute("Admin")
                    .As("Versions");

                builder.Register(unityContainer.Resolve<Middleware.RuleEndpoint>())
                    //.RunOnRoute("Admin")
                    .As("Rule");

                builder.Register(unityContainer.Resolve<Middleware.RulesEndpoint>())
                    //.RunOnRoute("Admin")
                    .As("Rules");

                builder.Register(unityContainer.Resolve<Middleware.RuleNamesEndpoint>())
                    //.RunOnRoute("Admin")
                    .As("RuleNames");

                builder.Register(unityContainer.Resolve<Middleware.PostRuleEndpoint>())
                    //.RunOnRoute("Admin")
                    .As("Post rule");

                builder.Register(unityContainer.Resolve<Middleware.TestEndpoint>())
                    //.RunOnRoute("Admin")
                    .As("Test");

                /******************************************************************************
                 * Middleware to serve the Dart UI
                 *****************************************************************************/

                builder.Register(unityContainer.Resolve<VersioningMiddleware>())
                    //.RunOnRoute("UI")
                    .As("Versioning")
                    .ConfigureWith(config, "/urchin/server/ui/versioning");

                builder.Register(unityContainer.Resolve<DartMiddleware>())
                    //.RunOnRoute("UI")
                    .As("Dart")
                    .ConfigureWith(config, "/urchin/server/ui/dart");

                builder.Register(unityContainer.Resolve<LessMiddleware>())
                    //.RunOnRoute("UI")
                    .As("Less")
                    .RunAfter("Dart")
                    .ConfigureWith(config, "/urchin/server/ui/less");

                builder.Register(unityContainer.Resolve<StaticFilesMiddleware>())
                    //.RunOnRoute("UI")
                    .As("Static files")
                    .RunAfter("Dart")
                    .ConfigureWith(config, "/urchin/server/ui/staticFiles");

                /******************************************************************************
                 * Middleware that needs to run last
                 *****************************************************************************/

                builder.Register(unityContainer.Resolve<NotFoundMiddleware>())
                    //.RunOnRoute("Ops")
                    //.RunOnRoute("Admin")
                    .As("Not found")
                    .RunLast()
                    .ConfigureWith(config, "/urchin/server/notFound");
            
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
        private IDisposable ConfigureUrchinClient(IUnityContainer unityContainer)
        {
            var hostingEnvironment = unityContainer.Resolve<IHostingEnvironment>();
            var fileName = hostingEnvironment.MapPath("Urchin.json");
            var fileInfo = new FileInfo(fileName);

            var configurationSource = unityContainer.Resolve<FileSource>().Initialize(fileInfo, TimeSpan.FromSeconds(10));

            return configurationSource;
        }
    }
}