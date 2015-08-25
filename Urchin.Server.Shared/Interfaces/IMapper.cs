namespace Urchin.Server.Shared.Interfaces
{
    public interface IMapper
    {
        TDestination Map<TSource, TDestination>(TSource source, string mappingName = null) where TDestination : class;
        TDestination Map<TSource, TDestination>(TSource source, TDestination destination, string mappingName = null);
    }
}
