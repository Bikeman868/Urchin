using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Owin;
using Newtonsoft.Json;
using OwinFramework.Builder;
using OwinFramework.Interfaces.Builder;
using OwinFramework.InterfacesV1.Middleware;

namespace Urchin.Server.Owin.Middleware
{
    public class GetUserEndpoint: ApiBase, IMiddleware<object>
    {
        private readonly PathString _userPath;

        public GetUserEndpoint()
        {
            _userPath = new PathString("/user");

            this.RunAfter<IIdentification>();
            this.RunAfter<IAuthorization>();
        }

        public override Task Invoke(IOwinContext context, Func<Task> next)
        {
            var request = context.Request;

            if (request.Method == "GET" && request.Path.StartsWithSegments(_userPath))
                return HandleGetUser(context);

            return next.Invoke();
        }

        private Task HandleGetUser(IOwinContext context)
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
            }

            if (clientCredentials.IsLoggedOn)
            {
                var authorization = context.GetFeature<IAuthorization>();

                if (authorization != null)
                {
                    clientCredentials.IsAdministrator = authorization.HasPermission(Permissions.Administration, null);
                }
            }

            return Json(context, clientCredentials);
        }

        private class ClientCredentialsDto
        {
            [JsonProperty("ip")]
            public string IpAddress { get; set; }

            [JsonProperty("admin")]
            public bool IsAdministrator { get; set; }

            [JsonProperty("loggedOn")]
            public bool IsLoggedOn { get; set; }

            [JsonProperty("userName")]
            public string Username { get; set; }
        }
    }
}
