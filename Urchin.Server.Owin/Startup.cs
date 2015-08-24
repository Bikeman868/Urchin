using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Web.Configuration;
using Microsoft.Owin;
using Microsoft.Owin.BuilderProperties;
using Microsoft.Practices.Unity;
using Owin;
using Stockhouse.Shared.Contracts.Interfaces.DataTransformation;
using Urchin.Client.Interfaces;
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

#if DEBUG
            var endTime = DateTime.UtcNow.AddSeconds(10);
            while (DateTime.UtcNow < endTime && !System.Diagnostics.Debugger.IsAttached)
                System.Threading.Thread.Sleep(100);
#endif

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
            unityContainer.RegisterType<IPersister, FilePersister>(new ContainerControlledLifetimeManager());

            var registrar = new UnityRegistrar(unityContainer);
            var iocConfigs = GetIocConfigs(unityContainer);

            foreach (var config in iocConfigs)
                config.RegisterDependencies(registrar);

            return unityContainer;
        }

        private class UnityRegistrar: IIocRegistrar
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
        }

        private IEnumerable<IIocConfig> GetIocConfigs(UnityContainer unityContainer)
        {
            var dependencyDefinitionInterface = typeof(IIocConfig);
            return Shared.TypeMappings.ReflectionHelper.GetTypes(t => t.IsClass && dependencyDefinitionInterface.IsAssignableFrom(t))
                .Select(t => unityContainer.Resolve(t))
                .Cast<IIocConfig>()
                .OrderBy(c => c.OrderIndex);
        }

        private void ConfigureMiddleware(IAppBuilder app, UnityContainer unityContainer)
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