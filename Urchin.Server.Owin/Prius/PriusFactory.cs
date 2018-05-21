using System;
using Microsoft.Practices.Unity;
using Prius.Contracts.Interfaces.External;

namespace Urchin.Server.Owin.Prius
{
    internal class PriusFactory : IFactory
    {
        public static UnityContainer Unity;

        public object Create(Type type)
        {
            return Unity.Resolve(type);
        }

        public T Create<T>() where T : class
        {
            return Unity.Resolve<T>();
        }
    }
}
