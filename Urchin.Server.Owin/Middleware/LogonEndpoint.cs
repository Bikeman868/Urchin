using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Owin;
using Newtonsoft.Json.Linq;
using OwinFramework.Builder;
using OwinFramework.Interfaces.Builder;
using OwinFramework.InterfacesV1.Capability;
using OwinFramework.InterfacesV1.Middleware;
using OwinFramework.InterfacesV1.Upstream;
using OwinFramework.MiddlewareHelpers.Identification;
using Urchin.Server.Owin.Extensions;
using Urchin.Server.Shared.DataContracts;

namespace Urchin.Server.Owin.Middleware
{
    public class LogonEndpoint: 
        ApiBase, 
        IDisposable, 
        IConfigurable,
        IMiddleware<IIdentification>, 
        IUpstreamCommunicator<IUpstreamSession>
    {
        private readonly PathString _logonPath;
        private readonly PathString _logoffPath;

        private readonly IDictionary<string, Identification> _loggedOnUsers = new Dictionary<string, Identification>();
        private IDisposable _configChangeNotifier;
        private Config _config;

        private const string SessionVariableName = "LogonId";

        public LogonEndpoint()
        {
            _logonPath = new PathString("/logon");
            _logoffPath = new PathString("/logoff");

            ConfigurationChanged(new Config());

            this.RunAfter<ISession>();
        }

        public void Dispose()
        {
            _configChangeNotifier.Dispose();
        }

        public void Configure(IConfiguration configuration, string path)
        {
            _configChangeNotifier = configuration.Register(path, ConfigurationChanged, new Config());
        }

        private void ConfigurationChanged(Config config)
        {
            _config = config;
        }

        public Task RouteRequest(IOwinContext context, Func<Task> next)
        {
            // Tell the session middleware that a session must be established for 
            // the request if the request is routed through this logon middleware
            var upstreamSession = context.GetFeature<IUpstreamSession>();
            if (upstreamSession != null)
            {
                if (upstreamSession.EstablishSession())
                    IdentifyUser(context);
            }

            // Continue routing the request
            return next();
        }

        public override Task Invoke(IOwinContext context, Func<Task> next)
        {
            var session = context.GetFeature<ISession>();
            if (session == null)
            {
                UserIsAnonymous(context, null);
                return next();
            }

            var request = context.Request;

            if (request.Method == "POST")
            {
                if (_logonPath.IsWildcardMatch(request.Path))
                    return HandleLogon(context, request, session);

                if (_logoffPath.IsWildcardMatch(request.Path))
                    return HandleLogoff(context, session);
            }

            var identification = context.GetFeature<IIdentification>();
            if (identification == null) IdentifyUser(context);

            return next.Invoke();
        }

        private void IdentifyUser(IOwinContext context)
        {
            Identification identification;

            var session = context.GetFeature<ISession>();
            if (session == null || session.HasSession == false)
            {
                UserIsAnonymous(context, null);
                return;
            }

            var logonId = session.Get<string>(SessionVariableName);
            if (string.IsNullOrEmpty(logonId))
            {
                logonId = Guid.NewGuid().ToShortString();
                session.Set(SessionVariableName, logonId);
            }

            lock (_loggedOnUsers)
            {
                if (!_loggedOnUsers.TryGetValue(logonId, out identification))
                {
                    identification = UserIsAnonymous(context, logonId);
                    _loggedOnUsers.Add(logonId, identification);
                }
            }

            context.SetFeature<IIdentification>(identification);
        }

        Identification UserIsAnonymous(IOwinContext context, string identity)
        {
            var identification = new Identification
            {
                Identity = identity,
                Claims = new List<IIdentityClaim>
                    {
                        new IdentityClaim 
                        { 
                            Name = "ip-address", 
                            Value = context.Request.RemoteIpAddress, 
                            Status = ClaimStatus.Verified
                        }
                    },
                IsAnonymous = true
            };
            context.SetFeature<IIdentification>(identification);
            return identification;
        }

        private Task HandleLogon(IOwinContext context, IOwinRequest request, ISession session)
        {
            JToken requestBody;
            try
            {
                using (var sr = new StreamReader(request.Body, Encoding.UTF8))
                    requestBody = JToken.Parse(sr.ReadToEnd());
            }
            catch (Exception ex)
            {
                return Json(context, new PostResponseDto { Success = false, ErrorMessage = "Failed to read request body. " + ex.Message });
            }

            var bodyJson = requestBody as JObject;
            if (bodyJson == null)
                return Json(context, new PostResponseDto { Success = false, ErrorMessage = "Request body is not in the expected format." });

            var usernameElement = bodyJson["username"];
            var passwordElement = bodyJson["password"];

            if (usernameElement == null || passwordElement == null)
                return Json(context, new PostResponseDto { Success = false, ErrorMessage = "username and password are required for logon." });

            var username = usernameElement.Value<string>();
            var password = passwordElement.Value<string>();

            if (string.Equals(password, _config.AdministratorPassword, StringComparison.Ordinal))
            {
                var logonId = Logon(context, session, username);
                return Json(context, new PostResponseDto { Success = true, Id = logonId });
            }
            return Json(context, new PostResponseDto { Success = false, ErrorMessage = "Logon failed for user " + username });
        }

        private Task HandleLogoff(IOwinContext context, ISession session)
        {
            Logoff(session);
            session.Set(SessionVariableName, string.Empty);
            return Json(context, new PostResponseDto { Success = true });
        }

        private string Logon(IOwinContext context, ISession session, string username)
        {
            var logonId = session.Get<string>(SessionVariableName);
            if (string.IsNullOrEmpty(logonId))
            {
                logonId = Guid.NewGuid().ToShortString();
                session.Set(SessionVariableName, logonId);
            }

            Identification identification;

            lock (_loggedOnUsers)
            {
                if (!_loggedOnUsers.TryGetValue(logonId, out identification))
                {
                    identification = new Identification();
                    _loggedOnUsers.Add(logonId, identification);
                }
            }

            identification.IsAnonymous = false;
            identification.Identity = logonId;
            identification.Claims = new List<IIdentityClaim>
                {
                    new IdentityClaim {Name = "username", Value = username, Status = ClaimStatus.Verified},
                    new IdentityClaim {Name = "ip-address", Value = context.Request.RemoteIpAddress, Status = ClaimStatus.Verified}
                };
            identification.Purposes = null;

            return logonId;
        }

        private void Logoff(ISession session)
        {
            var logonId = session.Get<string>(SessionVariableName);

            if (!string.IsNullOrEmpty(logonId))
            {
                lock (_loggedOnUsers)
                {
                    _loggedOnUsers.Remove(logonId);
                }
            }
        }

        private class Identification: IIdentification, IUpstreamIdentification
        {
            public IList<IIdentityClaim> Claims { get; set; }
            public string Identity { get; set; }
            public bool IsAnonymous { get; set; }
            public IList<string> Purposes { get; set; }
            public bool AllowAnonymous { get; set; }
        }

        public class Config
        {
            public Config()
            {
                AdministratorPassword = "administrator";
                CookieName = "urchin_session";
            }

            public string AdministratorPassword { get; set; }
            public string CookieName { get; set; }
        }
    }
}
