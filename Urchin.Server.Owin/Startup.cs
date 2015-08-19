using System;
using System.Web.Configuration;
using Microsoft.Owin;
using Microsoft.Owin.BuilderProperties;
using Microsoft.Practices.Unity;
using Owin;
using Urchin.Server.Owin;
using Urchin.Server.Shared.Data;
using Urchin.Server.Shared.Interfaces;

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
            app.Use(iocContainer.Resolve<Middleware.GetConfiguration>().Invoke);
            app.Use(iocContainer.Resolve<Middleware.Hello>().Invoke);
        }
    }
}