namespace Urchin.Server.Shared.Interfaces
{
    public interface IIocConfig
    {
        int OrderIndex { get; }
        void RegisterDependencies(IIocRegistrar registrar);
    }
}
