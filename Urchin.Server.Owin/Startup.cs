using System;
using System.Web.Configuration;
using Microsoft.Owin;
using Microsoft.Owin.BuilderProperties;
using Microsoft.Practices.Unity;
using Owin;
using Stockhouse.Shared.Contracts.Interfaces.DataTransformation;
using Urchin.Server.Owin;
using Urchin.Server.Shared.Interfaces;
using Urchin.Server.Shared.Rules;
using Urchin.Server.Shared.TypeMappings;

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
        }
    }
}