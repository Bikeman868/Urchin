namespace Stockhouse.Shared.Contracts.Interfaces.DataTransformation
{
    public interface IMapper
    {
        TDestination Map<TSource, TDestination>(TSource source, string mappingName = null) where TDestination : class;
        TDestination Map<TSource, TDestination>(TSource source, TDestination destination, string mappingName = null);
    }
}
