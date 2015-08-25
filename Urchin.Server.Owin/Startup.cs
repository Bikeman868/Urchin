using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using Common.Logging;
using Microsoft.Owin;
using Microsoft.Owin.BuilderProperties;
using Microsoft.Practices.Unity;
using Owin;
using Stockhouse.Shared.Contracts.Interfaces.DataTransformation;
using Urchin.Server.Owin;
using Urchin.Server.Shared.Interfaces;
using Urchin.Server.Shared.Rules;
using Mapper = Urchin.Server.Shared.TypeMappings.Mapper;

[assembly: OwinStartup(typeof(Startup))]

namespace Urchin.Server.Owin
{
    public class Startup
    {
        public void Configuration(IAppBuilder app)
        {

//#if DEBUG
//            var endTime = DateTime.UtcNow.AddSeconds(10);
//            while (DateTime.UtcNow < endTime && !System.Diagnostics.Debugger.IsAttached)
//                System.Threading.Thread.Sleep(100);
//#endif

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

        private UnityContainer ConfigureUnity()
        {
            var unityContainer = new UnityContainer();
            unityContainer.RegisterType<IConfigRules, ConfigRules>(new ContainerControlledLifetimeManager());
            unityContainer.RegisterType<IMapper, Mapper>(new ContainerControlledLifetimeManager());
            unityContainer.RegisterType<ILogManager, LogManager>(new ContainerControlledLifetimeManager());

            // Register the default persister. If you include the DLLs from any
            // other persister, it will override this registration and become the 
            // persister for your installation.
            unityContainer.RegisterType<IPersister, FilePersister>(new ContainerControlledLifetimeManager());

            var iocConfigs = GetIocConfigs(unityContainer);

            // The code below will dynamically load any IOC registrations from
            // additional libraries that are deployed to the bin folder. This
            // is the mechanism for replacing the persistence mechanism.
            var registrar = new UnityRegistrar(unityContainer);
            unityContainer.RegisterInstance<IIocRegistrar>(registrar);
            unityContainer.RegisterInstance<IIocFactory>(registrar);
            foreach (var config in iocConfigs)
                config.RegisterDependencies(registrar);

            return unityContainer;
        }

        /// <summary>
        /// Implements IIocRegistrar and IIocFactory using Unity. These interfaces allow
        /// add on modules to register themselves with the IoC container without knowing
        /// which IoC is being used.
        /// </summary>
        private class UnityRegistrar: IIocRegistrar, IIocFactory
        {
            private readonly UnityContainer _container;

            public UnityRegistrar(UnityContainer container)
            {
                _container = container;
            }

            public void RegisterSingleton<TInterface, TClass>()
                where TInterface : class
                where TClass : class, TInterface
            {
                _container.RegisterType<TInterface, TClass>(new ContainerControlledLifetimeManager());
            }

            public void RegisterType<TInterface, TClass>()
                where TInterface : class
                where TClass : class, TInterface
            {
                _container.RegisterType<TInterface, TClass>(new ExternallyControlledLifetimeManager());
            }

            public T Create<T>()
            {
                return _container.Resolve<T>();
            }
        }

        /// <summary>
        /// Scans all DLLs in the bin folder, and finds classes that register interface
        /// mappings in IOC. This provides a mechanism for changing the behaviour of the
        /// urchin server by simply dropping a DLL into the bin folder. An example
        /// of this is the Prius persister. By adding this to the bin folder, the
        /// standard file persister is replaced by the database persister.
        /// </summary>
        private IEnumerable<IIocConfig> GetIocConfigs(UnityContainer unityContainer)
        {
            var dependencyDefinitionInterface = typeof(IIocConfig);
            return Shared.TypeMappings.ReflectionHelper.GetTypes(t => t.IsClass && dependencyDefinitionInterface.IsAssignableFrom(t))
                .Select(t => unityContainer.Resolve(t))
                .Cast<IIocConfig>()
                .OrderBy(c => c.OrderIndex);
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
                app.Use(unityContainer.Resolve<Middleware.ConfigEndpoint>().Invoke);
                app.Use(unityContainer.Resolve<Middleware.HelloEndpoint>().Invoke);
                app.Use(unityContainer.Resolve<Middleware.TraceEndpoint>().Invoke);
                app.Use(unityContainer.Resolve<Middleware.DefaultEnvironmentEndpoint>().Invoke);
                app.Use(unityContainer.Resolve<Middleware.EnvironmentsEndpoint>().Invoke);
                app.Use(unityContainer.Resolve<Middleware.RuleEndpoint>().Invoke);
                app.Use(unityContainer.Resolve<Middleware.RulesEndpoint>().Invoke);
                app.Use(unityContainer.Resolve<Middleware.PostRuleEndpoint>().Invoke);
                app.Use(unityContainer.Resolve<Middleware.RuleDataEndpoint>().Invoke);
                app.Use(unityContainer.Resolve<Middleware.TestEndpoint>().Invoke);
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
            }
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
            var fileName = "config.txt";
            var thisAssembly = Assembly.GetExecutingAssembly();
            var codeBaseUri = new Uri(thisAssembly.CodeBase);
            if (codeBaseUri.IsFile)
            {
                var binFolderPath = Path.GetDirectoryName(codeBaseUri.LocalPath);
                var siteFolderPath = Directory.GetParent(binFolderPath).FullName;
                fileName = Path.Combine(siteFolderPath, fileName);
            }
            var fileInfo = new FileInfo(fileName);

            var configurationStore = new Client.Data.ConfigurationStore().Initialize();
            var configurationSource = new Client.Sources.FileSource(configurationStore).Initialize(fileInfo, TimeSpan.FromSeconds(10));

            unityContainer.RegisterInstance(configurationStore);
            unityContainer.RegisterInstance(configurationSource);

            return configurationSource;
        }
    }
}