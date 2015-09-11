using System;
using System.Threading.Tasks;
using System.Web;
using Microsoft.Owin;
using Urchin.Server.Owin.Extensions;
using Urchin.Server.Shared.DataContracts;
using Urchin.Server.Shared.Interfaces;

namespace Urchin.Server.Owin.Middleware
{
    public class VersionsEndpoint: ApiBase
    {
        private readonly IRuleData _ruleData;
        private readonly PathString _path;

        public VersionsEndpoint(
            IRuleData ruleData)
        {
            _ruleData = ruleData;
            _path = new PathString("/versions");
        }

        public Task Invoke(IOwinContext context, Func<Task> next)
        {
            var request = context.Request;
            if (!_path.IsWildcardMatch(request.Path))
                return next.Invoke();

            try
            {
                if (request.Method == "GET")
                    return GetVersions(context);

                if (request.Method == "DELETE")
                    return DeleteOldVersions(context);
            }
            catch (Exception ex)
            {
                if (ex is HttpException) throw;
                return Json(context, new PostResponseDto { Success = false, ErrorMessage = ex.Message });
            }

            return next.Invoke();
        }

        private Task GetVersions(IOwinContext context)
        {
            var versions = _ruleData.GetVersions();
            return Json(context, versions);
        }

        private Task DeleteOldVersions(IOwinContext context)
        {
            _ruleData.DeleteOldVersions();
            return Json(context, new PostResponseDto { Success = true });
        }
    }
}