# Urchin
A rules based centralized enterprise configuration management solution for .Net

## Client Features
* All configuration data is strongly typed and has default values.
* Configuration is defined in JSON format (not XML).
* Application code can register for notification when specific configuration
  values change, or specific objects within the configuration change.
* Register for notification at any level of the configuration heirachy.
* Supports all JSON data types including arrays, strings, numbers, boolean and objects.
* Sections of the configuration can be deserialized to object graphs with no setup.
* Configuration can be stored in a file, or at a URI.
* Migration path from exiting .Net ConfigurationManager implementation.

## Quick start
This is the quickest way to get up and running.
* Install these NuGet Packages: `Ioc.Modules`, `Ioc.Modules.Ninject`, `Urchin.Client`
* Create a file in the root folder of your project called `config.json` and add some configuration data to it in JSON format. For example
````
   {
      "myApp":{
        "logging":{
          "path":"C:\\temp"
        }
      }
   }
````

* Add the following code where it will run at startup:
````
    var packageLocator = new PackageLocator().ProbeBinFolderAssemblies();
    var ninject = new StandardKernel(new Ioc.Modules.Ninject.Module(packageLocator));
    var configFile = new FileInfo(AppDomain.CurrentDomain.SetupInformation.ApplicationBase + "config.json");
    var urchinSource = ninject.Get<FileSource>().Initialize(configFile, TimeSpan.FromSeconds(5));
````
> This will use the package locator from `IoC.Modules` to configure a Ninject IoC container, then it uses
> Ninject to construct an Urchin `FileSource` class to get the Urchin configuration from the `config.json` file.
> Note that you should maintain a reference to the `FileSource` if you want it to notice changes to the config
> file.

> Note that this example uses the Urchin `FileSource`. Urchin has other sources available, most notably the 
> `UriSource` which will get config Json from a URI instead of a file path. This is how you would integrate 
> the Urchin server. The Urchin server provides centralized rules-based configuration management system.

> Note that IoC.Modules supports the most popular IoC containers and is very easy to integrate with any other
> IoC. This example uses Ninject but switching to any other IoC is a trivial change. See the readme for `Ioc.Modules` 
> for details on how to do this.

* Anywhere in your application where you need configuration data, add a dependency on the Urchin `IConfigurationStore` 
interface and call its methods to get configuration data. For example:
````
    public class LoggingConfig
    {
        public string Path { get; set; }

        public LoggingConfig()
        {
            Path = "C:\\Temp\\Logs";
        }
    }

    public class MyApplicationClass
    {
        private LoggingConfig _loggingConfig;
        private IDisposable _loggingConfigChangeNotification;

        public MyApplicationClass(IConfigurationStore configurationStore)
        {
            _loggingConfigChangeNotification = configurationStore.Register(
                "/myApp/logging", 
                cfg => _loggingConfig = cfg,
                new LoggingConfig());
        }
    }
````
> In this example the `LoggingConfig` class should match the structure of the data
> in your `config.json` file under the path `/myApp/logging`. Urchin will use the
> Newtonsoft Json package to hydrate this class from this section of the config file.

## Server Features
* Rules based configuration based on environment, datacenter, machine, application and instance.
* Centralized configuration management with REST API and configuration mananagement UI.
* Urchin Client can pull config by polling the server at a URL that includes query
  string parameters to specify machine, datacenter, application, environment and instance.
* Rules for determining environment from machine so that this is an optional parameter.
* Rules for determining datacenter from environment, machine, application and instance so that
  this parameter is optional.
* Variable declaration and substitution.
* IP based security with administrator logon to override.
* Versioning of rules with different versions active in each environment.

## Things that Urchin does _not_ do
* I can't find any way to get ASP.NET to give up on using the web.config file for
  its configuration settings. Microsoft provide no flexibility or extensibility at
  all in this area, so fo now, you can only use Urchin for settings specific to
  your application.
  
## Known issues
There have been reports of issues with the database persistence module. It looks
like some issues might have been introduces with the switch to versioning of rules.
My advice for now is to use the default persistence mechanism that saves all the
rules to a single file. This is the mechanism that was used during development,
has received extensive testing and seems to be completely solid. I have used this
in a number of very high traffic enterprise systems with no issues whatsoever.

Please contact the owner if you are experiencing any other issues.

## Contents
| Component | Description |
| --------- | ----------- |
| `Urchin.Client` | Add this to your application via NuGet to get access to configuration data |
| `Urchin.Client.Tests` | Unit tests for Urchin.Client |
| `Urchin.Server.Owin` | Install this on IIS to provide rules based centralized configuration repository |
| `Urchin.Server.Shared` | Core server-side technology. Shared by hosting options |
| `Urchin.Server.Persistence.Prius` | Install this to persist your rules to a database |

## Project Status
The client is complete and fully stable. It has a comprehensive set of unit tests.

The client can retrieve configuration from a file, or a URI. The URI method can be used to retrieve 
configuration from the Urchin server; which gives you rule based centralized configuration
management.

The server is ready, and is deployed in one production environment that I know of. You can 
configure the server to store its rules in a single file in json format or in a database. 
The database persister uses Prius ORM, which supports Microsoft SQL Server, MySQL and 
Postgresql, but so far I have only created database schema and stored procedures for MySQL.

The server has a REST API for managing the rule database. If you are using the file persister, then 
you can edit the file and the changes will be picked up and applied by the server. If you are using 
the Prius persister to save changes to a database, and you edit the database directly, you will have
to recycle the IIS app pool to pick up the changes.

A UI for managing rules is in development. The editor is a single page application written in the 
Dart programming language. It allows you to manage all of the rules, versions and environments, but
has limited funtionallity in the areas of: testing rules before applying changes, duplicating rules,
copying rules between versions, user accounts and granular permissions. These features will be
built into future versions of the UI.

## Next Steps
If you want to contribute to this project, these are the next most important tasks

* Change input boxes for application, environment and datacenter to drop-down lists.
* Fix issues with the database persistence package.
* Write scripts to create databases for Microsoft SQL Server and Postgresql.
* Add user accounts and granular permissions.
* Add UI functionallity to move/copy rules between versions.
* Add UI functionallity to test rule changes before saving them.
* Maintain an audit trail of who changed what when.
* Add an alternate UI view which is based around config values rather than rules. In this paradigm the rules would be maintained behind the scenes.

## FAQ

Q: Do I need to use the server component?

A: No, you can use the client stand alone with a configuration file, or a URI 
   that returns the configuration data.

---

Q: How do I get started?

A: To get started with the client only using IoC and a local configuration file:
   1. Install the NuGet package for `Urchin.Client`.
   2. In your IoC register a mapping to the `ConfigurationStore` class from the
      `IConfigurationStore` interface as a singleton. Note that if you integrate
      the `Ioc.Modules` NuGet package into application you can skip this step.
   3. Create a configuration file in JSON format. Structure the JSON however you
      want including different data types, arrays and objects within objects.
   4. Construct an instance of `Urchin.Client.Sources.FileSource` and initialize
      it with the location of your file. You will have to pass an
      `IConfigurationStore` instance to the constructor - you can let IoC do this
      for you! You need to keep a reference to the `FileSource` for it to notice 
      config changes. When you `Dispose()` of the `FileSource` it will stop 
      watching the configuration file for changes.
   5. Inject `IConfigurationStore` into classes in your application that need 
      access to configuration data.
   6. Call the `Register<T>()` method of `IConfigurationStore` to get notified 
      of the initial config values, and whenever config changes later.

---

Q: What's the best way to see what I can do with the client?

A: Take a look at the unit tests for `ConfigurationStore` in `Urchin.Client.Tests`

---

Q: How do I install and configure the server?

A: The server doesn't have an installer yet. You need to get the source code from
   git and compile it. See [Urchin OWIN server](https://github.com/Bikeman868/Urchin/tree/master/Urchin.Server.Owin) readme for full details.

---

Q: After I register for configuration changes, how do I get the initial values?

A: When you register for changes, your change handler will be called right away
   with the current values, then called again if anything changes later.

---

Q: Do I have to register for changes, or can I just read the configuration?

A: You can read the configuration, the `IConfigurationStore` has a `Get<T>()`
   method for that purpose, but it is not designed to be called frequently,
   so call it once only at startup, not every time your code needs the
   configured value.

---

Q: How do I know what path to use when I register with IConfigurationStore?

A: The path parameter is the path to a node in the JSON configuration file.
   Use / separators to go from a JSON object to one of its properties.
   For example in this JSON `{section1:{value1:23,value2:87},section2:{}}`
   A path of /section1/value1 refers to the number 23.

---

Q: Do I have to register for each configuration value in my JSON?

A: No, you can register for notifications at any level of the configuration heirachy
   including the root. When you register a JSON object, specify a .Net class 
   that can be deserialized from this JSON. For example if you have this 
   JSON configuration:
```
       {
         section1:{value1:23,value2:87},
         section2:{value1:19,value2:43}
       }
```
   You can write a C# class like this:
```
       public class SectionConfig
       {
         public int Value1 { get; set; }
         public int Value2 { get; set; }
       }
```
   Then you can register with the `IConfigurationStore` like this:
```
       private readonly IConfigurationStore _config;
       public void Initialize()
       {
	      _config.Register<SectionConfig>("/section1", Section1Changed);
	      _config.Register<SectionConfig>("/section2", Section2Changed);
       }
       private void Section1Changed(SectionConfig section1)
       {
       }
       private void Section2Changed(SectionConfig section2)
       {
       }
```
---

Q: Can I implement my own source of configuration data?

A: Yes, call the `UpdateConfiguration()` method of `IConfigurationStore` with the
   configuration data in JSON format and it will identify all the changes for you 
   and call the registerd change handlers. If nothing changed then it will return 
   immediately without doing anything.

---

Q: Can I store all my configuration in a shared database?

A: Yes, store the configuration in your database in JSON format, then retrieve it 
   from the database and pass it to the `UpdateConfiguration()` method of 
   `IConfigurationStore`. If nothing changed then it will return immediately without
   doing anything.

---

Q: Can I make sure my configuration is valid before applying it to my application?

A: Yes, when you `Initialize()` the `ConfigurationStore`, you can optionally pass an
   implementation of `IConfigurationValidator`. Your validator will only get called
   if the configuration changed, and if it returns `false` then the configuration
   will not be applied.

---

Q: How can I see when there are errors in my configuration?

A: When you `Initialize()` the `ConfigurationStore`, you can optionally pass an
   implementation of `IErrorLogger`. When you do this, all errors will be passed
   to your implementation so that you can report them any way you choose.

---

Q: I already use the `ConfigurationManager` and `appSettings` in my application's config
   file. Can I start using Urchin without migrating all my code or duplicating my
   configuration?

A: Yes, but this is a short-term stop gap. Right now if you go this route, all of
   your configuration will have to be maintained in `appSettings` until you have 
   migrated all of your code to Urchin.
   To do this, construct an instance of `ConfigurationManagerSource` and call it's 
   `LoadConfiguration()` method. Then register for changes with the path /appSettings/name.
   For example if you have this your my web.config file:
```
       <appSettings>
         <add key="cacheDuration" value="34"/>
       </appSettings>
```
   You can register for changes in cache duration with this code:
```
       private readonly IConfigurationStore _config;
       public void Initialize()
       {
         _config.Register<int>("/appSettings/cacheDuration", CacheDurationChanged);
       }
       public void CacheDurationChanged(int cacheDuration)
       {
       }
```
---

Q: Can I specify default values in my application so that I only need to configure
   things that are not the default value?

A: Yes, when you call the `Register<T>()` method of `IConfigurationStore` you can optionally
   pass a default value which will apply when there is no value specified in the
   configuration data.

---

Q: What is your recommended best practice for managing config?

A: I recommend that you define a class that serializes to the config values you want. this
   is extensible later. For example if you are writting a logger, and need to confgure the
   file path, even though you only have one config value and you might be tempted to
   register a string in the config file, I suggest you regisrer a class with one property
   instead, because it makes it easy to add more config options later.
   In this example, the `LoggerConfiguration` class has properties that will be deserialized
   from the configuration data. It also has a default public constructor that specifies the 
   default values that apply when these properties are not configured.
   When the notification handler is registered, it constructs a default instance of 
   `LoggerConfiguration` that will be used when the entire logger configuration is absent
   from the configuration data.
   The configuration JSON should be similar to `{"myapp":{"logger":{"filePath":"L:\\logfile.txt"}}}`
```
    public class Logger: IDisposable
    {
      private readonly IDisposable _configurationNotifier;
      
      public Logger(IConfigurationStore configurationStore)
      {
        _configurationNotifier = configurationStore.Register("/myapp/logger", SetConfiguration, new LoggerConfiguration());
      }
      
      public void Dispose()
      {
        _configurationNotifier.Dispose();
      }
      
      private void SetConfiguration(LoggerConfiguration loggerConfiguration)
      {
        // ... etc
      }
      
      public class LoggerConfiguration
      {
        public LoggerConfiguration()
        {
          FilePath = @"C:\Temp\Log.txt";
        }
        
        public string FilePath { get; set; }
      }
    }
```
---

Q: What is your recommended best practice for specifying paths in the config data?

A: I recommend that you have 2 or three levels deep, with the application name or library name in the 
   first level, then the class or module name second level. And if the second level is a module, then
   the class name at the third level.
   For example if your application is called MyApp and it uses third party libraries called Prius and
   Urchin, you will have config that has similar structure to what is shown below. In this example class 1
   from module 1 would register for config changes in `/myApp/module1/class1`.
```
    {
        "myApp":
        {
            "myClass":{"setting1":value1, "setting2":value2},
            "module1":
            {
                "class1":{"setting1":value1, "setting2":value2},
                "class2":{"setting1":value1, "setting2":value2},
                "class3":{"setting1":value1, "setting2":value2}
            },
            "module2":
            {
                "class1":{"setting1":value1, "setting2":value2},
                "class2":{"setting1":value1, "setting2":value2},
                "class3":{"setting1":value1, "setting2":value2}
            }
        },
        "prius":
        {
        },
        "urchin":
        {
        }
    }
```
