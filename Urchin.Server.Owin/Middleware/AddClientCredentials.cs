using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Owin;
using OwinFramework.Builder;
using OwinFramework.Interfaces.Builder;
using OwinFramework.InterfacesV1.Middleware;
using Urchin.Server.Shared.Interfaces;
using Urchin.Server.Shared.Rules;

namespace Urchin.Server.Owin.Middleware
{
    /// <summary>
    /// This is temporary during the refactoring of the identification and authorization
    /// mechanism. When the rest of the middleware checks permissions using the
    /// IAuthorization middleware this middleware will no longer be needed.
    /// </summary>
    public class AddClientCredentials: ApiBase, IMiddleware<object>
    {
        public AddClientCredentials()
        {
            this.RunAfter<IIdentification>();
        }

        public override Task Invoke(IOwinContext context, Func<Task> next)
        {
            var clientCredentials = new ClientCredentialsDto
            {
                IsLoggedOn = false,
                Username = string.Empty,
                IpAddress = string.Empty,
                IsAdministrator = false
            };

            var identification = context.GetFeature<IIdentification>();

            if (identification != null)
            {
                var usernameClaim = identification.Claims
                    .FirstOrDefault(c => string.Equals(c.Name, "username", StringComparison.OrdinalIgnoreCase));

                if (usernameClaim != null)
                    clientCredentials.Username = usernameClaim.Value;

                var ipaddressClaim = identification.Claims
                    .FirstOrDefault(c => string.Equals(c.Name, "ip-address", StringComparison.OrdinalIgnoreCase));

                if (ipaddressClaim != null)
                    clientCredentials.IpAddress = ipaddressClaim.Value;

                clientCredentials.IsLoggedOn = !identification.IsAnonymous;
                clientCredentials.IsAdministrator = clientCredentials.IsLoggedOn;
            }

            context.Set<IClientCredentials>("ClientCredentials", clientCredentials);

            return next.Invoke();
        }
    }
}
