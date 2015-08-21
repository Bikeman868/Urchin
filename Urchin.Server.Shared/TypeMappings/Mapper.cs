using System;
using Stockhouse.Shared.Contracts.Interfaces.DataTransformation;

namespace Urchin.Server.Shared.TypeMappings
{
    public class Mapper : IMapper
    {
        private static bool _initialized;

        public Mapper()
        {
            Initialize();
        }

        public TDestination Map<TSource, TDestination>(TSource obj, string mappingName) where TDestination : class
        {
            if (mappingName == null)
                return AutoMapper.Mapper.Map<TSource, TDestination>(obj);

            throw new NotImplementedException("Work in progress. Name in mapping not supported yet.");
        }

        public TDestination Map<TSource, TDestination>(TSource source, TDestination destination, string mappingName)
        {
            if (mappingName == null)
                return AutoMapper.Mapper.Map(source, destination);

            throw new NotImplementedException("Work in progress. Name in mapping not supported yet.");
        }

        public static void Initialize()
        {
            if (_initialized) return;

            _initialized = true;

            var profileType = typeof(AutoMapper.Profile);
            AutoMapper.Mapper.Initialize(
                cfg =>
                {
                    Func<Type, bool> typeSelector = t => t != profileType && profileType.IsAssignableFrom(t);

                    foreach (var type in ReflectionHelper.GetTypes(typeSelector))
                    {
                        var constructor = type.GetConstructor(Type.EmptyTypes);
                        if (constructor == null)
                            throw new Exception("Unable to get default public constructor for type " + type.FullName);
                        try
                        {
                            var instance = (AutoMapper.Profile)(constructor.Invoke(null));
                            cfg.AddProfile(instance);
                        }
                        catch (Exception ex)
                        {
                            throw new Exception("Failed to initialize type" + type.FullName, ex);
                        }
                    }
                });

            AutoMapper.Mapper.AssertConfigurationIsValid();
        }

    }
}
