namespace Urchin.Server.Shared.Interfaces
{
    public interface IFactory
    {
        T Create<T>();
    }

}
