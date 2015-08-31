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
    public class UiEndpoint: ApiBase
    {
        private readonly PathString _uiUrlPathPattern;
        private readonly PathString _faviconUrlPath;
        private readonly DirectoryInfo _uiDirectoryInfo;
        private readonly IDictionary<string, FileWrapper> _fileCache;
        private readonly IDictionary<string, FileTypeInfo> _fileTypes;
        private readonly IDisposable _versionChangeRegistration;
        private readonly FileTypeInfo _defaultFileTypeInfo;

        private int _version;

        public UiEndpoint(
            IConfigurationStore configurationStore)
        {
            _versionChangeRegistration = configurationStore.Register("/urchin/server/version", v => _version = v, 1);
            _uiUrlPathPattern = new PathString("/ui/{file}");
            _faviconUrlPath = new PathString("/favicon.ico");

            var uiRootPath =  System.Web.Hosting.HostingEnvironment.MapPath("~/ui.dart/web");
            if (string.IsNullOrEmpty(uiRootPath))
                return;
            _uiDirectoryInfo = new DirectoryInfo(uiRootPath);

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
                {".dart", new FileTypeInfo{MimeType = "application/javascript", Expiry = TimeSpan.FromHours(1), Processing = FileProcessing.Dart}},
            };

            _fileTypes.Add(".htm", _fileTypes[".html"]);
            _fileTypes.Add(".shtml", _fileTypes[".html"]);

            _defaultFileTypeInfo = _fileTypes[".html"];

            _fileCache = new Dictionary<string, FileWrapper>();

            _fileCache.Add("favicon.ico", new FileWrapper(
                _uiDirectoryInfo,
                "favicon.ico", 
                new FileTypeInfo { MimeType = "image/ico", Expiry = TimeSpan.FromHours(4) }));
        }

        public Task Invoke(IOwinContext context, Func<Task> next)
        {
            var request = context.Request;
            
            if (request.Method != "GET")
                return next.Invoke();

            if (_uiUrlPathPattern.IsWildcardMatch(request.Path))
                return ServeUi(context);

            if (_faviconUrlPath.IsWildcardMatch(request.Path))
                return ServeFavicon(context);

            return next.Invoke();
        }

        private Task ServeUi(IOwinContext context)
        {
            if (_uiDirectoryInfo == null)
                throw new HttpException((int)HttpStatusCode.ServiceUnavailable, "Unable to determine location of files to serve");

            var request = context.Request;

            var pathSegmnts = request.Path.Value
                .Split('/')
                .Where(p => !string.IsNullOrWhiteSpace(p))
                .Select(HttpUtility.UrlDecode)
                .ToArray();

            if (pathSegmnts.Length < 2)
                throw new HttpException((int)HttpStatusCode.BadRequest, "Path has too few segments. Expecting " + _uiUrlPathPattern.Value);

            var fileName = pathSegmnts[1];
            bool isVersioned;
            var wrapper = GetWrapper(fileName, out isVersioned);

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

            var extension = Path.GetExtension(fileName);
            var baseFileName = Path.GetFileNameWithoutExtension(fileName);

            var versionSuffix = "_v" + _version;
            isVersioned = baseFileName.EndsWith(versionSuffix);
            if (isVersioned)
            {
                var fileNameWithoutVersion = baseFileName.Substring(0, baseFileName.Length - versionSuffix.Length);
                fileName = fileNameWithoutVersion + extension;
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
                    context.Response.Expires = DateTime.UtcNow + _fileTypeInfo.Expiry;
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