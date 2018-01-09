using System;
using System.IO;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using Microsoft.Owin;
using Newtonsoft.Json.Linq;
using OwinFramework.Interfaces.Builder;
using Urchin.Server.Owin.Extensions;
using Urchin.Server.Shared.DataContracts;
using Urchin.Server.Shared.Interfaces;

namespace Urchin.Server.Owin.Middleware
{
    public class DefaultEnvironmentEndpoint : ApiBase, IMiddleware<object>
    {
        private readonly IRuleData _ruleData;
        private readonly PathString _path;

        public DefaultEnvironmentEndpoint(
            IRuleData ruleData)
        {
            _ruleData = ruleData;
            _path = new PathString("/environment/default");
        }

        public override Task Invoke(IOwinContext context, Func<Task> next)
        {
            var request = context.Request;
            if (!_path.IsWildcardMatch(request.Path))
                return next.Invoke();

            if (request.Method == "GET")
            {
                try
                {
                    return GetDefaultEnvironment(context);
                }
                catch (Exception ex)
                {
                    if (ex is HttpException) throw;
                    throw new HttpException((int) HttpStatusCode.InternalServerError,
                        "Exception getting default environment. " + ex.Message, ex);
                }
            }

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

            if (request.Method == "PUT")
            {
                try
                {
                    return UpdateDefaultEnvironment(context, requestBody.Value<string>());
                }
                catch (Exception ex)
                {
                    return Json(context,
                        new PostResponseDto
                        {
                            Success = false,
                            ErrorMessage = ex.Message
                        });
                }
            }

            return next.Invoke();
        }

        private Task GetDefaultEnvironment(IOwinContext context)
        {
            return Json(context, _ruleData.GetDefaultEnvironment());
        }

        private Task UpdateDefaultEnvironment(IOwinContext context, string requestBody)
        {
            if (string.IsNullOrWhiteSpace(requestBody))
                return Json(context, new PostResponseDto { Success = false, ErrorMessage = "The default environment name can not be blank" });

            if (requestBody.Length > 80)
                return Json(context, new PostResponseDto { Success = false, ErrorMessage = "The default environment name is too long" });

            var clientCredentials = context.Get<IClientCredentials>("ClientCredentials");
            _ruleData.SetDefaultEnvironment(clientCredentials, requestBody);

            return Json(context, new PostResponseDto { Success = true });
        }
    }
}