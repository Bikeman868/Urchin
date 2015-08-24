namespace Urchin.Server.Shared.Interfaces
{
    public interface IIocRegistrar
    {
        void RegisterSingleton<TInterface, TClass>()
            where TInterface : class
            where TClass : class, TInterface;

        void RegisterType<TInterface, TClass>()
            where TInterface : class
            where TClass : class, TInterface;
    }
}
