#define ROUTING
//#define BREAK_ON_STARTUP

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

#if ROUTING
using OwinFramework.Interfaces.Routing;
#endif

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

#if ROUTING
                var configPath = new PathString("/config");
                var opsPath = new PathString("/ops");
                var uiPath = new PathString("/ui");

                builder.Register(unityContainer.Resolve<IRouter>())
                    .AddRoute("Config", c => c.Request.Path.StartsWithSegments(configPath))
                    .AddRoute("Ops", c => c.Request.Path.StartsWithSegments(opsPath))
                    .AddRoute("Ui", c => c.Request.Path.StartsWithSegments(uiPath))
                    .AddRoute("Admin", c => true)
                    .As("Router");
#endif                
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
#if ROUTING
                    .RunOnRoute("Config")
#endif
                    .As("Config");

                /******************************************************************************
                 * Middleware to help the ops team to manage the Urchin service
                 *****************************************************************************/

                builder.Register(unityContainer.Resolve<Middleware.HelloEndpoint>())
#if ROUTING
                    .RunOnRoute("Ops")
#endif
                    .As("Hello");

                builder.Register(unityContainer.Resolve<Middleware.TraceEndpoint>())
#if ROUTING
                    .RunOnRoute("Admin")
#endif
                    .As("Trace");

                builder.Register(unityContainer.Resolve<DocumenterMiddleware>())
#if ROUTING
                    .RunOnRoute("Ops")
#endif
                    .As("Endpoint documenter")
                    .ConfigureWith(config, "/urchin/server/endpointDocumenter");

                builder.Register(unityContainer.Resolve<AnalysisReporterMiddleware>())
#if ROUTING
                    .RunOnRoute("Ops")
#endif
                    .As("Analysis reporter")
                    .ConfigureWith(config, "/urchin/server/analysisReporter");

                builder.Register(unityContainer.Resolve<RouteVisualizerMiddleware>())
#if ROUTING
                    .RunOnRoute("Ops")
#endif
                    .As("Route visualizer")
                    .ConfigureWith(config, "/urchin/server/visualizer");

                /******************************************************************************
                 * Middleware to configure Urchin
                 *****************************************************************************/

                builder.Register(unityContainer.Resolve<Middleware.DefaultEnvironmentEndpoint>())
#if ROUTING
                    .RunOnRoute("Admin")
#endif
                    .As("Default environment");

                builder.Register(unityContainer.Resolve<Middleware.EnvironmentsEndpoint>())
#if ROUTING
                    .RunOnRoute("Admin")
#endif
                    .As("Environments");

                builder.Register(unityContainer.Resolve<Middleware.VersionEndpoint>())
#if ROUTING
                    .RunOnRoute("Admin")
#endif
                    .As("Version");

                builder.Register(unityContainer.Resolve<Middleware.VersionsEndpoint>())
#if ROUTING
                    .RunOnRoute("Admin")
#endif
                    .As("Versions");

                builder.Register(unityContainer.Resolve<Middleware.RuleEndpoint>())
#if ROUTING
                    .RunOnRoute("Admin")
#endif
                    .As("Rule");

                builder.Register(unityContainer.Resolve<Middleware.RulesEndpoint>())
#if ROUTING
                    .RunOnRoute("Admin")
#endif
                    .As("Rules");

                builder.Register(unityContainer.Resolve<Middleware.RuleNamesEndpoint>())
#if ROUTING
                    .RunOnRoute("Admin")
#endif
                    .As("RuleNames");

                builder.Register(unityContainer.Resolve<Middleware.PostRuleEndpoint>())
#if ROUTING
                    .RunOnRoute("Admin")
#endif
                    .As("Post rule");

                builder.Register(unityContainer.Resolve<Middleware.TestEndpoint>())
#if ROUTING
                    .RunOnRoute("Admin")
#endif
                    .As("Test");

                /******************************************************************************
                 * Middleware to serve the Dart UI
                 *****************************************************************************/

                builder.Register(unityContainer.Resolve<VersioningMiddleware>())
#if ROUTING
                    .RunOnRoute("UI")
#endif
                    .As("Versioning")
                    .ConfigureWith(config, "/urchin/server/ui/versioning");

                builder.Register(unityContainer.Resolve<DartMiddleware>())
#if ROUTING
                    .RunOnRoute("UI")
#endif
                    .As("Dart")
                    .ConfigureWith(config, "/urchin/server/ui/dart");

                builder.Register(unityContainer.Resolve<LessMiddleware>())
#if ROUTING
                    .RunOnRoute("UI")
#endif
                    .As("Less")
                    .RunAfter("Dart")
                    .ConfigureWith(config, "/urchin/server/ui/less");

                builder.Register(unityContainer.Resolve<StaticFilesMiddleware>())
#if ROUTING
                    .RunOnRoute("UI")
#endif
                    .As("Static files")
                    .RunAfter("Dart")
                    .ConfigureWith(config, "/urchin/server/ui/staticFiles");

                /******************************************************************************
                 * Middleware that needs to run last
                 *****************************************************************************/

                builder.Register(unityContainer.Resolve<NotFoundMiddleware>())
#if ROUTING
                    .RunOnRoute("Ops")
                    .RunOnRoute("Admin")
#endif
                    .As("Not found")
                    .RunLast()
                    .ConfigureWith(config, "/urchin/server/notFound");

#if BREAK_ON_STARTUP
                while (!System.Diagnostics.Debugger.IsAttached)
                    System.Threading.Thread.Sleep(50);
                System.Diagnostics.Debugger.Break();
#endif

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
                log.FatalFormat("Failed to construct OWIN middleware pipeline.\r\n{0}\r\n{1}\r\n{2}", ex.Message, ex.StackTrace, innerExceptions);
                throw;
            }
        }

        private void ConfigureFailedMiddleware(IAppBuilder app, Exception exception)
        {
            app.Use(new Middleware.FailedSetupMiddleware(exception).Invoke);
        }

        /// <summary>
        /// Configures Urchin client to read ita configuration from a file in the
        /// main folder of the site. This file will be used to configure the server 
        /// and also to configure other modules that use Urchin (like Prius for example).
        /// Note that you should configure your web site to not serve this file.
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