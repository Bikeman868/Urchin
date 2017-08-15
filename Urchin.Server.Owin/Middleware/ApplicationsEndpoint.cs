using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using Microsoft.Owin;
using Newtonsoft.Json;
using OwinFramework.Interfaces.Builder;
using Urchin.Server.Owin.Extensions;
using Urchin.Server.Shared.DataContracts;
using Urchin.Server.Shared.Interfaces;

namespace Urchin.Server.Owin.Middleware
{
    public class ApplicationsEndpoint : ApiBase, IMiddleware<object>
    {
        private readonly IRuleData _ruleData;
        private readonly PathString _path;

        public ApplicationsEndpoint(
            IRuleData ruleData)
        {
            _ruleData = ruleData;
            _path = new PathString("/applications");
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
                    return GetApplications(context);
                }
                catch (Exception ex)
                {
                    if (ex is HttpException) throw;
                    throw new HttpException((int) HttpStatusCode.InternalServerError,
                        "Exception getting list of applications. " + ex.Message, ex);
                }
            }

            List<ApplicationDto> applications;
            try
            {
                using (var sr = new StreamReader(request.Body, Encoding.UTF8))
                    applications = JsonConvert.DeserializeObject<List<ApplicationDto>>(sr.ReadToEnd());
            }
            catch (Exception ex)
            {
                return Json(context, new PostResponseDto { Success = false, ErrorMessage = "Failed to deserialize request body to a list of applications. " + ex.Message });
            }

            if (request.Method == "PUT")
            {
                try
                {
                    return UpdateApplications(context, applications);
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

        private Task GetApplications(IOwinContext context)
        {
            var clientCredentials = context.Get<IClientCredentials>("ClientCredentials");
            var applications = _ruleData.GetApplications(clientCredentials);
            return Json(context, applications);
        }

        private Task UpdateApplications(IOwinContext context, List<ApplicationDto> applications)
        {
            var clientCredentials = context.Get<IClientCredentials>("ClientCredentials");
            _ruleData.SetApplications(clientCredentials, applications);
            return Json(context, new PostResponseDto { Success = true });
        }
    }
}