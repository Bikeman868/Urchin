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
        private readonly IDictionary<string, FileTypeInfo> _fileTypes;
        private readonly List<IDisposable> _disposables;
        private readonly FileTypeInfo _defaultFileTypeInfo;

        private int _version;
        private DirectoryInfo _uiDirectoryInfo;
        private IDictionary<string, FileWrapper> _fileCache;
        private PathString _uiRootUrlPathPattern;
        private PathString _faviconUrlPath;

        public UiEndpoint(
            IConfigurationStore configurationStore)
        {
            _fileTypes = new Dictionary<string, FileTypeInfo>()
            {
                {".avi", new FileTypeInfo{MimeType = "video/avi", Expiry = TimeSpan.FromDays(7)}},
                {".mov", new FileTypeInfo{MimeType = "video/quicktime", Expiry = TimeSpan.FromDays(7)}},
                {".mp3", new FileTypeInfo{MimeType = "video/mpeg", Expiry = TimeSpan.FromDays(7)}},

                {".bmp", new FileTypeInfo{MimeType = "image/bmp", Expiry = TimeSpan.FromDays(7)}},
                {".ico", new FileTypeInfo{MimeType = "image/ico", Expiry = TimeSpan.FromDays(7)}},
                {".jpg", new FileTypeInfo{MimeType = "image/jpeg", Expiry = TimeSpan.FromDays(7)}},
                {".jfif", new FileTypeInfo{MimeType = "image/jpeg", Expiry = TimeSpan.FromDays(7)}},
                {".jpeg", new FileTypeInfo{MimeType = "image/jpeg", Expiry = TimeSpan.FromDays(7)}},
                {".png", new FileTypeInfo{MimeType = "image/png", Expiry = TimeSpan.FromDays(7)}},
                {".tif", new FileTypeInfo{MimeType = "image/tif", Expiry = TimeSpan.FromDays(7)}},
                {".tiff", new FileTypeInfo{MimeType = "image/tif", Expiry = TimeSpan.FromDays(7)}},
                {".gif", new FileTypeInfo{MimeType = "image/gif", Expiry = TimeSpan.FromDays(7)}},

                {".html", new FileTypeInfo{MimeType = "text/html", Expiry = TimeSpan.FromHours(1), Processing = FileProcessing.Html}},
                {".txt", new FileTypeInfo{MimeType = "text/plain"}},
                {".css", new FileTypeInfo{MimeType = "text/css", Expiry = TimeSpan.FromDays(7), Processing = FileProcessing.Css}},

                {".js", new FileTypeInfo{MimeType = "application/javascript", Expiry = TimeSpan.FromHours(1), Processing = FileProcessing.JavaScript}},
                {".dart", new FileTypeInfo{MimeType = "application/dart", Expiry = TimeSpan.FromHours(1), Processing = FileProcessing.Dart}},
            };

            _fileTypes.Add(".htm", _fileTypes[".html"]);
            _fileTypes.Add(".shtml", _fileTypes[".html"]);

            _defaultFileTypeInfo = _fileTypes[".html"];

            _disposables = new List<IDisposable>();
            _disposables.Add(configurationStore.Register("/urchin/server/version", v => _version = v, 1));
            _disposables.Add(configurationStore.Register("/urchin/server/ui/url", p => _uiRootUrlPathPattern = new PathString(p), "/ui"));
            _disposables.Add(configurationStore.Register("/urchin/server/ui/faviconUrl", u => _faviconUrlPath = new PathString(u), "/favicon.ico"));
            _disposables.Add(configurationStore.Register("/urchin/server/ui/physicalPath", PhysicalPathChanged, "~/ui/build/web"));
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

            var uiDirectoryInfo = new DirectoryInfo(uiRootPath);

            var fileCache = new Dictionary<string, FileWrapper>();

            fileCache.Add("favicon.ico", new FileWrapper(
                uiDirectoryInfo,
                "favicon.ico",
                new FileTypeInfo { MimeType = "image/ico", Expiry = TimeSpan.FromHours(4) }));

            _uiDirectoryInfo = uiDirectoryInfo;
            _fileCache = fileCache;
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

            var wrapper = _fileCache["favicon.ico"];
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

            FileWrapper wrapper;
            lock (_fileCache)
            {
                if (_fileCache.TryGetValue(fileName, out wrapper)) return wrapper;

                FileTypeInfo fileTypeInfo;
                lock (_fileTypes)
                {
                    if (!_fileTypes.TryGetValue(extension, out fileTypeInfo))
                        fileTypeInfo = _defaultFileTypeInfo;
                }

                wrapper = new FileWrapper(_uiDirectoryInfo, fileName, fileTypeInfo);
                _fileCache.Add(fileName, wrapper);
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
            private readonly FileInfo _fileInfo;
            private readonly FileTypeInfo _fileTypeInfo;

            private byte[] _content;
            private DateTime _lastModified;
            private int _version;

            public FileWrapper(DirectoryInfo rootDirectory, string relativePath, FileTypeInfo fileTypeInfo)
            {
                _fileInfo = new FileInfo(Path.Combine(rootDirectory.FullName, relativePath));
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
                if (_content == null || !_fileInfo.Exists || version != _version) return true;
                return _fileInfo.LastWriteTimeUtc > _lastModified || (DateTime.UtcNow - _lastModified) > TimeSpan.FromMinutes(5);
            }

            private void ReadFile(int version)
            {
                _version = version;
                if (!_fileInfo.Exists)
                {
                    _lastModified = DateTime.UtcNow;
                    _content = null;
                    return;
                }

                try
                {
                    using (var stream = _fileInfo.Open(FileMode.Open, FileAccess.Read, FileShare.Read))
                    {
                        var length = (int)stream.Length;
                        _content = new byte[length];
                        stream.Read(_content, 0, length);
                    }
                    _lastModified = _fileInfo.LastWriteTimeUtc;

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