using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Owin;
using Newtonsoft.Json.Linq;
using OwinFramework.Interfaces.Builder;
using Urchin.Client.Interfaces;
using Urchin.Server.Owin.Extensions;
using Urchin.Server.Shared.DataContracts;
using Urchin.Server.Shared.Rules;

namespace Urchin.Server.Owin.Middleware
{
    public class LogonEndpoint: ApiBase, IDisposable, IMiddleware<object>
    {
        private readonly IDisposable _configChangeNotifier;
        private readonly PathString _logonPath;
        private readonly PathString _logoffPath;
        private readonly PathString _userPath;
        private readonly IDictionary<string, SessionToken> _sessionTokens;

        private Config _config;
        private TimeSpan _sessionTimeout;

        public LogonEndpoint(IConfigurationStore configurationStore)
        {
            _configChangeNotifier = configurationStore.Register("/urchin/server/logon", SetConfig, new Config());

            _logonPath = new PathString("/logon");
            _logoffPath = new PathString("/logoff");
            _userPath = new PathString("/user");
            _sessionTokens = new Dictionary<string, SessionToken>();
        }

        public void Dispose()
        {
            _configChangeNotifier.Dispose();
        }

        public override Task Invoke(IOwinContext context, Func<Task> next)
        {
            var request = context.Request;

            var clientCredentials = new ClientCredentialsDto 
            {
                IpAddress = context.Request.RemoteIpAddress
            };
            if (clientCredentials.IpAddress == "::1")
                clientCredentials.IpAddress = "127.0.0.1";

            context.Set("ClientCredentials", clientCredentials);

            SessionToken sessionToken = null;
            var sessionCookie = request.Cookies[_config.CookieName];
            if (sessionCookie != null)
            {
                lock(_sessionTokens)
                {
                    if (_sessionTokens.TryGetValue(sessionCookie, out sessionToken))
                    {
                        if (DateTime.UtcNow > sessionToken.Expiry)
                        {
                            _sessionTokens.Remove(sessionCookie);
                        }
                        else
                        {
                            clientCredentials.IsLoggedOn = true;
                            clientCredentials.Username = sessionToken.Username;
                            clientCredentials.IsAdministrator = string.Equals(sessionToken.IpAddress, clientCredentials.IpAddress, StringComparison.Ordinal);
                        }
                    }
                }
            }

            if (request.Method == "GET" && _userPath.IsWildcardMatch(request.Path))
            {
                return Json(context, clientCredentials);
            }

            if (request.Method != "POST")
                return next.Invoke();

            if (_logonPath.IsWildcardMatch(request.Path))
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
                var userName = bodyJson["username"];
                var password = bodyJson["password"];

                if (userName == null || password == null)
                    return Json(context, new PostResponseDto { Success = false, ErrorMessage = "username and password are required for logon." });

                if (string.Equals(password.Value<string>(), _config.AdministratorPassword, StringComparison.Ordinal))
                {
                    var cookie = NewSession(clientCredentials.IpAddress, userName.Value<string>());
                    context.Response.Cookies.Append(_config.CookieName, cookie);
                    return Json(context, new PostResponseDto { Success = true, Id = cookie });
                }
                return Json(context, new PostResponseDto { Success = false, ErrorMessage = "Logon failed for user " + userName.Value<string>() });
            }
            if (_logoffPath.IsWildcardMatch(request.Path))
            {
                if (sessionToken != null)
                {
                    context.Response.Cookies.Delete(sessionToken.Token);
                    lock (_sessionTokens)
                        _sessionTokens.Remove(sessionToken.Token);
                }
                return Json(context, new PostResponseDto { Success = true });
            }

            return next.Invoke();
        }

        private void SetConfig(Config config)
        {
            _config = config;

            int days;
            if (int.TryParse(config.SessionExpiry, out days))
                _sessionTimeout = TimeSpan.FromDays(days);
            else if (!TimeSpan.TryParseExact(config.SessionExpiry, "c", CultureInfo.InvariantCulture, out _sessionTimeout))
                _sessionTimeout = TimeSpan.FromHours(1);
        }

        private string NewSession(string ipAddress, string userName)
        {
            var token = new SessionToken
            {
                Expiry = DateTime.UtcNow + _sessionTimeout,
                IpAddress = ipAddress,
                Token = Guid.NewGuid().ToString("n"),
                Username = userName
            };
            lock (_sessionTokens)
            {
                _sessionTokens.Add(token.Token, token);
            }
            return token.Token;
        }
    
        private class SessionToken
        {
            public string Token { get; set; }
            public string IpAddress { get; set; }
            public DateTime Expiry { get; set; }
            public string Username { get; set; }
        }

        public class Config
        {
            public Config()
            {
                AdministratorPassword = "administrator";
                SessionExpiry = TimeSpan.FromMinutes(30).ToString("c");
                CookieName = "urchin_session";
            }

            public string AdministratorPassword { get; set; }
            public string SessionExpiry { get; set; }
            public string CookieName { get; set; }
        }
    }
}
