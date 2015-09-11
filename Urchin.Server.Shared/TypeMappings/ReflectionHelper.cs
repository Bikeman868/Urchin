using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;

namespace Urchin.Server.Shared.TypeMappings
{
    public static class ReflectionHelper
    {
        private static IList<Assembly> _applicationAssemblies;

        public static IEnumerable<Assembly> GetApplicationAssemblies()
        {
            if (_applicationAssemblies == null)
            {
                var thisAssembly = Assembly.GetExecutingAssembly();
                var codeBaseUri = new Uri(thisAssembly.CodeBase);
                if (codeBaseUri.IsFile)
                {
                    var binFolderPath = Path.GetDirectoryName(codeBaseUri.LocalPath);
                    var assemblyFileNames = Directory.GetFiles(binFolderPath, "*.dll");
                    foreach (var assemblyFileName in assemblyFileNames)
                    {
                        var assemplyName = new AssemblyName(Path.GetFileNameWithoutExtension(assemblyFileName));
                        var assembly = AppDomain.CurrentDomain.Load(assemplyName);
                    }
                }

                _applicationAssemblies = AppDomain.CurrentDomain.GetAssemblies().ToList();
            }
            return _applicationAssemblies;
        }

        public static IEnumerable<Type> GetTypes(IEnumerable<Assembly> assemblies, Func<Type, bool> predicate)
        {
            return assemblies.SelectMany(
                a =>
                {
                    try
                    {
                        return a.GetTypes().Where(predicate);
                    }
                    catch
                    {
                        return new Type[] { };
                    }
                });
        }

        public static IEnumerable<Type> GetTypes(Func<Type, bool> predicate)
        {
            return GetTypes(GetApplicationAssemblies(), predicate);
        }

        public static IEnumerable<T> GetAttributes<T>(Type type, bool inherit = false)
        {
            foreach (var attribute in type.GetCustomAttributes(inherit))
            {
                if (attribute is T)
                {
                    yield return (T)attribute;
                }
            }
        }

        public static PropertyInfo GetProperty(Type type, string name, bool inherit = false)
        {
            var property = type.GetProperties()
                .FirstOrDefault(p => string.Compare(p.Name, name, StringComparison.InvariantCultureIgnoreCase) == 0);
            if (!inherit || property != null) return property;

            if (type.BaseType == null) return null;
            return GetProperty(type.BaseType, name, true);
        }
    }
}
