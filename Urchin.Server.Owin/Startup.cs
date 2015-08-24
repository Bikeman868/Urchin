using System;
using System.IO;
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
            var iocContainer = new UnityContainer();
            iocContainer.RegisterType<IConfigRules, ConfigRules>(new ContainerControlledLifetimeManager());
            iocContainer.RegisterType<IMapper, Mapper>(new ContainerControlledLifetimeManager());
            iocContainer.RegisterType<IPersister, FilePersister>(new ContainerControlledLifetimeManager());

            ConfigureUrchinClient(iocContainer);
            ConfigureMiddleware(app, iocContainer);

            var properties = new AppProperties(app.Properties);
            var token = properties.OnAppDisposing;
            token.Register(() =>
            {
                iocContainer.Dispose();
            });
        }

        private void ConfigureMiddleware(IAppBuilder app, UnityContainer iocContainer)
        {
            app.Use(iocContainer.Resolve<Middleware.ConfigEndpoint>().Invoke);
            app.Use(iocContainer.Resolve<Middleware.HelloEndpoint>().Invoke);
            app.Use(iocContainer.Resolve<Middleware.TraceEndpoint>().Invoke);
            app.Use(iocContainer.Resolve<Middleware.DefaultEnvironmentEndpoint>().Invoke);
            app.Use(iocContainer.Resolve<Middleware.EnvironmentsEndpoint>().Invoke);
            app.Use(iocContainer.Resolve<Middleware.RuleEndpoint>().Invoke);
            app.Use(iocContainer.Resolve<Middleware.RulesEndpoint>().Invoke);
            app.Use(iocContainer.Resolve<Middleware.PostRuleEndpoint>().Invoke);
            app.Use(iocContainer.Resolve<Middleware.RuleDataEndpoint>().Invoke);
            app.Use(iocContainer.Resolve<Middleware.TestEndpoint>().Invoke);
        }

        private void ConfigureUrchinClient(UnityContainer iocContainer)
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

            iocContainer.RegisterInstance(configurationStore);
            iocContainer.RegisterInstance(configurationSource);
        }
    }
}