using Microsoft.Owin;
using System;

namespace Urchin.Server.Owin.Extensions
{
    public static class OwinExtensions
    {
        public static bool IsWildcardMatch(this PathString wildcardPath, PathString path)
        {
            if (!wildcardPath.HasValue) return !path.HasValue;

            var wildcardSegments = wildcardPath.Value.Split('/');
            var segments = path.Value.Split('/');

            if (wildcardSegments.Length != segments.Length) return false;

            for (var i = 0; i < wildcardSegments.Length; i++)
            {
                if (wildcardSegments[i].StartsWith("{")) continue;
                if (!String.Equals(wildcardSegments[i], segments[i], StringComparison.InvariantCultureIgnoreCase))
                    return false;
            }

            return true;
        }

        public static bool StartsWith(this PathString wildcardPath, PathString path)
        {
            if (!wildcardPath.HasValue) return !path.HasValue;
            return wildcardPath.Value.StartsWith(path.Value);
        }
    }
}