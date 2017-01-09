using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Owin;
using Newtonsoft.Json;
using OwinFramework.Interfaces.Builder;

namespace Urchin.Server.Owin.Middleware
{
    public abstract class ApiBase: IMiddleware
    {
        private readonly IList<IDependency> _dependencies = new List<IDependency>();
        IList<IDependency> IMiddleware.Dependencies { get { return _dependencies; } }

        string IMiddleware.Name { get; set; }

        public abstract Task Invoke(IOwinContext context, Func<Task> next);

        
        protected Task Json<T>(IOwinContext context, T data)
        {
            context.Response.ContentType = "application/json";
            return context.Response.WriteAsync(JsonConvert.SerializeObject(data));
        }

        protected Task PlainText(IOwinContext context, string text)
        {
            context.Response.ContentType = "text/plain";
            return context.Response.WriteAsync(text);
        }

        protected Task PlainText(IOwinContext context, StringBuilder text)
        {
            context.Response.ContentType = "text/plain";
            return context.Response.WriteAsync(text.ToString());
        }
    }
}
