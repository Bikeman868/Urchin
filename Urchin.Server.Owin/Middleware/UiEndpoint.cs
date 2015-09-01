using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using Microsoft.Owin;
using Urchin.Client.Interfaces;
using Urchin.Server.Owin.Extensions;

namespace Urchin.Server.Owin.Middleware
{
    /// <summary>
    /// This middleware behaves a lot like the static files middleware with the
    /// following differences:
    /// - Files can be versioned. The version number comes from /urchin/server/version in the config file.
    /// - It maps the url /ui/* onto the physical path ui/build/web/*
    /// - It maps the url /favicon.ico onto the physical path ui/web/favicon.ico
    /// - If the url includes a version:
    ///    * If the version in the url does not match the current version a 404 is returned.
    ///    * If the version in the url is the the current version, the version number is
    ///      stripped out to get the name of the file to serve, and the file is served with
    ///      an expiry date, allowing the browser to cache the file.
    ///  - If the url does not include a version the file file is served to the browser with
    ///    no caching enabled so the browser will request the resource every time.
    ///  - In HTML files, the string {_v_} is replaced with the current version number before
    ///    being sent to the browser. This should be added to all links that refer to resources
    ///    such as javascript, css and images.
    /// </summary>
    public class UiEndpoint: ApiBase
    {
        private readonly List<IDisposable> _disposables;

        private FileTypeInfo _defaultFileTypeInfo;
        private IDictionary<string, FileTypeInfo> _fileTypes;
        private int _version;
        private DirectoryInfo _uiDirectoryInfo;
        private IDictionary<string, FileWrapper> _fileCache;
        private PathString _uiRootUrlPathPattern;
        private PathString _faviconUrlPath;
        private bool _enableCaching;

        public UiEndpoint(
            IConfigurationStore configurationStore)
        {
            _disposables = new List<IDisposable>();
            _disposables.Add(configurationStore.Register("/urchin/server/version", v => _version = v, 1));
            _disposables.Add(configurationStore.Register("/urchin/server/ui/url", p => _uiRootUrlPathPattern = new PathString(p), "/ui"));
            _disposables.Add(configurationStore.Register("/urchin/server/ui/faviconUrl", u => _faviconUrlPath = new PathString(u), "/favicon.ico"));
            _disposables.Add(configurationStore.Register("/urchin/server/ui/physicalPath", PhysicalPathChanged, "~/ui/build/web"));
            _disposables.Add(configurationStore.Register("/urchin/server/ui/cache", EnableCachingChanged, true));
        }

        public Task Invoke(IOwinContext context, Func<Task> next)
        {
            var request = context.Request;
            
            if (request.Method != "GET")
                return next.Invoke();

            if (_uiRootUrlPathPattern.IsWildcardMatch(request.Path))
                return ServeUiRoot(context);

            if (request.Path.StartsWith(_uiRootUrlPathPattern))
                return ServeUi(context);
           
            if (_faviconUrlPath.IsWildcardMatch(request.Path))
                return ServeFavicon(context);

            return next.Invoke();
        }

        private void PhysicalPathChanged(string physicalPath)
        {
            var uiRootPath = System.Web.Hosting.HostingEnvironment.MapPath(physicalPath);
            if (string.IsNullOrEmpty(uiRootPath)) return;

            _uiDirectoryInfo = new DirectoryInfo(uiRootPath);

            FlushFileCache();
        }

        private void EnableCachingChanged(bool enableCaching)
        {
            _enableCaching = enableCaching;
            DefineFileTypes();
            FlushFileCache();
        }

        private void FlushFileCache()
        {
            var fileCache = new Dictionary<string, FileWrapper>();

            fileCache.Add("favicon.ico", new FileWrapper(
                _uiDirectoryInfo,
                "favicon.ico",
                new FileTypeInfo { MimeType = "image/ico", Expiry = TimeSpan.FromHours(4) }));

            _fileCache = fileCache;
        }

        private void DefineFileTypes()
        {
            var oneWeek = _enableCaching ? TimeSpan.FromDays(7) : (TimeSpan?)null;
            var oneHour = _enableCaching ? TimeSpan.FromHours(1) : (TimeSpan?)null;

            var fileTypes = new Dictionary<string, FileTypeInfo>()
            {
                {".avi", new FileTypeInfo{MimeType = "video/avi", Expiry = oneWeek}},
                {".mov", new FileTypeInfo{MimeType = "video/quicktime", Expiry = oneWeek}},
                {".mp3", new FileTypeInfo{MimeType = "video/mpeg",  Expiry = oneWeek}},

                {".bmp", new FileTypeInfo{MimeType = "image/bmp",  Expiry = oneWeek}},
                {".ico", new FileTypeInfo{MimeType = "image/ico",  Expiry = oneWeek}},
                {".jpg", new FileTypeInfo{MimeType = "image/jpeg",  Expiry = oneWeek}},
                {".jfif", new FileTypeInfo{MimeType = "image/jpeg",  Expiry = oneWeek}},
                {".jpeg", new FileTypeInfo{MimeType = "image/jpeg",  Expiry = oneWeek}},
                {".png", new FileTypeInfo{MimeType = "image/png",  Expiry = oneWeek}},
                {".tif", new FileTypeInfo{MimeType = "image/tif",  Expiry = oneWeek}},
                {".tiff", new FileTypeInfo{MimeType = "image/tif",  Expiry = oneWeek}},
                {".gif", new FileTypeInfo{MimeType = "image/gif",  Expiry = oneWeek}},

                {".html", new FileTypeInfo{MimeType = "text/html", Expiry = oneHour, Processing = FileProcessing.Html}},
                {".txt", new FileTypeInfo{MimeType = "text/plain"}},
                {".css", new FileTypeInfo{MimeType = "text/css", Expiry = oneWeek, Processing = FileProcessing.Css}},

                {".js", new FileTypeInfo{MimeType = "application/javascript", Expiry = oneHour, Processing = FileProcessing.JavaScript}},
                {".dart", new FileTypeInfo{MimeType = "application/dart", Expiry = oneHour, Processing = FileProcessing.Dart}},
            };

            fileTypes.Add(".htm", fileTypes[".html"]);
            fileTypes.Add(".shtml", fileTypes[".html"]);

            _defaultFileTypeInfo = fileTypes[".html"];
            _fileTypes = fileTypes;
        }

        private Task ServeUi(IOwinContext context)
        {
            if (_uiDirectoryInfo == null)
                throw new HttpException((int)HttpStatusCode.ServiceUnavailable, "Unable to determine location of files to serve");

            var request = context.Request;

            var path = request.Path.Value.Substring(_uiRootUrlPathPattern.Value.Length + 1);
            var fileName = path.Replace('/', '\\');

            bool isVersioned;
            var wrapper = GetWrapper(fileName, out isVersioned);

            return wrapper.Send(context, _version, isVersioned);
        }

        private Task ServeUiRoot(IOwinContext context)
        {
            if (_uiDirectoryInfo == null)
                throw new HttpException((int)HttpStatusCode.ServiceUnavailable, "Unable to determine location of files to serve");

            bool isVersioned;
            var wrapper = GetWrapper("index.html", out isVersioned);

            return wrapper.Send(context, _version, isVersioned);
        }

        private Task ServeFavicon(IOwinContext context)
        {
            if (_uiDirectoryInfo == null)
                throw new HttpException((int)HttpStatusCode.ServiceUnavailable, "Unable to determine location of files to serve");

            var fileCache = _fileCache;
            FileWrapper wrapper;
            lock (fileCache) wrapper = fileCache["favicon.ico"];
            return wrapper.Send(context, 1, true);
        }

        private FileWrapper GetWrapper(string fileName, out bool isVersioned)
        {
            isVersioned = false;
            if (string.IsNullOrWhiteSpace(fileName)) return null;

            var lastDirectorySeparatorIndex = fileName.LastIndexOf('\\');
            var firstPeriodIndex = lastDirectorySeparatorIndex < 0 
                ? fileName.IndexOf('.') 
                : fileName.IndexOf('.', lastDirectorySeparatorIndex);
            var lastPeriodIndex = fileName.LastIndexOf('.');

            var fullExtension = firstPeriodIndex < 0 ? "" : fileName.Substring(firstPeriodIndex);
            var extension = lastPeriodIndex < 0 ? "" : fileName.Substring(lastPeriodIndex);
            var baseFileName = firstPeriodIndex < 0 ? fileName : fileName.Substring(0, firstPeriodIndex);

            var versionSuffix = "_v" + _version;
            isVersioned = baseFileName.EndsWith(versionSuffix);
            if (isVersioned)
            {
                var fileNameWithoutVersion = baseFileName.Substring(0, baseFileName.Length - versionSuffix.Length);
                fileName = fileNameWithoutVersion + fullExtension;
            }

            var fileCache = _fileCache;
            FileWrapper wrapper;
            lock (fileCache)
            {
                if (fileCache.TryGetValue(fileName, out wrapper)) return wrapper;

                var fileTypes = _fileTypes;
                FileTypeInfo fileTypeInfo;
                lock (fileTypes)
                {
                    if (!fileTypes.TryGetValue(extension, out fileTypeInfo))
                        fileTypeInfo = _defaultFileTypeInfo;
                }

                wrapper = new FileWrapper(_uiDirectoryInfo, fileName, fileTypeInfo);
                fileCache.Add(fileName, wrapper);
            }
            return wrapper;
        }

        private enum FileProcessing { None, Html, Css, Dart, JavaScript }

        private class FileTypeInfo
        {
            public TimeSpan? Expiry;
            public string MimeType;
            public FileProcessing Processing;
        }

        private class FileWrapper
        {
            private readonly string _fullFilePath;
            private readonly FileTypeInfo _fileTypeInfo;

            private byte[] _content;
            private DateTime _lastModified;
            private int _version;

            public FileWrapper(DirectoryInfo rootDirectory, string relativePath, FileTypeInfo fileTypeInfo)
            {
                _fullFilePath = Path.Combine(rootDirectory.FullName, relativePath);
                _fileTypeInfo = fileTypeInfo;
            }

            public Task Send(IOwinContext context, int version, bool isVersioned)
            {
                if (HasChanged(version)) ReadFile(version);

                if (_content == null)
                    throw new HttpException((int)HttpStatusCode.NotFound, "The requested content could not be found");

                context.Response.ContentType = _fileTypeInfo.MimeType;
                if (isVersioned && _fileTypeInfo.Expiry.HasValue)
                {
                    context.Response.Expires = DateTime.UtcNow + _fileTypeInfo.Expiry;
                    context.Response.Headers.Set("Cache-Control", "public, max-age=" + (int)_fileTypeInfo.Expiry.Value.TotalSeconds);
                }
                else
                {
                    context.Response.Headers.Set("Cache-Control", "no-cache");
                }
                return context.Response.WriteAsync(_content);
            }

            private bool HasChanged(int version)
            {
                var fileInfo = new FileInfo(_fullFilePath);
                if (_content == null || !fileInfo.Exists || version != _version) return true;
                return fileInfo.LastWriteTimeUtc > _lastModified || (DateTime.UtcNow - _lastModified) > TimeSpan.FromMinutes(5);
            }

            private void ReadFile(int version)
            {
                _version = version;

                var fileInfo = new FileInfo(_fullFilePath);
                if (!fileInfo.Exists)
                {
                    _lastModified = DateTime.UtcNow;
                    _content = null;
                    return;
                }

                try
                {
                    using (var stream = fileInfo.Open(FileMode.Open, FileAccess.Read, FileShare.Read))
                    {
                        var length = (int)stream.Length;
                        _content = new byte[length];
                        stream.Read(_content, 0, length);
                    }
                    _lastModified = fileInfo.LastWriteTimeUtc;

                    if (_fileTypeInfo.Processing == FileProcessing.None) return;

                    var encoding = Encoding.UTF8;
                    var text = encoding.GetString(_content);
                    switch (_fileTypeInfo.Processing)
                    {
                        case FileProcessing.Html:
                            text = text.Replace("{_v_}", "_v" + version);
                            break;
                    }
                    _content = encoding.GetBytes(text);
                }
                catch
                {
                    _lastModified = DateTime.UtcNow;
                    _content = new byte[0];
                }
            }
        }
    }
}