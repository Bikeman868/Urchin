namespace Urchin.Server.Shared.Interfaces
{
    public interface IIocFactory
    {
        T Create<T>();
    }

}
