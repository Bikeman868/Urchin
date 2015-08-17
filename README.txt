Urchin
======
A rules based centralized enterprise configuration management solution for .Net

Features
========
Client
* All configuration data is strongly typed and has default values.
* Configuration is defined in JSON format (not XML).
* Application code can register for notification when specific configuration
  values change, or specific objects within the configuration change.
* Register for notification at any level of the configuration heirachy.
* Supports all JSON data types including arrays, strings, numbers, boolean and objects.
* Sections of the configuration can be deserialized to object graphs with no setup.
* Configuration can be stored in a file, or at a URI.
* Migration path from exiting .Net ConfigurationManager implementation.

Server
* Rules based configuration based on environment, machine, application and instance.
* Centralized configuration management with REST API and configuration mananagement UI.
* Urchin Client can pull config by polling the server at a URL that includes query
  string parameters to specify machine, application, environment and instance.
* Rules for determining environment from machine so that this is an optional parameter.

Contents
========
Urchin.Client
	Add this to your application via NuGet to get access to configuration data.

Urchin.Server.Owin
	Install this on IIS to provide rules based cenrtalized configuration repository.

Project Status
==============
The client is complete and fully usable. It has a comprehensive set of unit tests.

The client can retrieve configuration from a file, or a URI. Later the URI will
be used to retrieve configuration from the Urchin server, but the server is not
ready yet.

FAQ
===

Q: Do I need to use the server component?
A: No, you can use the client stand alone with a configuration file, or a URI 
   that returns the configuration data.

Q: How do I get started?
A: To get started with the client only using IoC and a local configuration file:
   1. Install the NuGet package for Urchin.Client.
   2. In your IoC register a mapping to the ConfigurationStore class from the
      IConfigurationStore interface as a singleton.
   3. Create a configuration file in JSON format. Structure the JSON however you
      want including different data types, arrays and objects within objects.
   4. Construct an instance of Urchin.Client.Sources.FileSource and initialize
      it with the location of your file. You will have to pass IConfigurationStore 
	  to the constructor - you can let IoC do this for you!
	  You need to keep a reference to the FileSource for it to notice config changes.
	  When you dispose of the FileSource it will stop watching the configuration
	  file for changes.
   5. Inject IConfigurationStore into classes in your application that need 
      access to configuration data.
   6. Call the Register<T>() method of IConfigurationStore to get notified 
      of the initial config values, and when config changes.

Q: What's the best way to see what I can do with the client?
A: Take a look at the unit tests for ConfigurationStore in Urchin.Client.Tests

Q: After I register for configuration changes, how do I get the initial values?
A: When you register for changes, your change handler will be called right away
   with the current values, then called again if anything changes later.

Q: Do I have to register for changes, or can I just read the configuration?
A: You can read the configuration, the IConfigurationStore has a Get<T>()
   method for that purpose, but it is not designed to be called frequently,
   so call it once only at startup, not every time your code needs the
   configured value.

Q: How do I know what path to use when I register with IConfigurationStore?
A: The path parameter is the path to a node in the JSON configuration file.
   Use / separators to go move from a JSON object to one of its properties.
   For example in this JSON {section1:{value1:23,value2:87},section2:{}}
   A path of /section1/value1 refers to the number 23.

Q: Do I have to register for each configuration value in my JSON?
A: No, you can register for notifications at any level of the configuration heirachy
   including the root. When you register a JSON object, specify a .Net class 
   that can be deserialized from this JSON. For example if you have this 
   JSON configuration:

       {
         section1:{value1:23,value2:87},
         section2:{value1:19,value2:43}
       }

   You can write a C# class like this:

       public class SectionConfig
       {
         public int Value1 { get; set; }
         public int Value2 { get; set; }
       }

	Then you can register with the IConfigurationStore like this:

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

Q: Can I implement my own source of configuration data?
A: Yes, call the UpdateConfiguration() method of IConfigurationStore with the
   configuration data in Json format and it will identify all the changes for you 
   and call the registerd change handlers. If nothing changed then it will return 
   immediately without doing anything.

Q: Can I store all my configuration in a shared database?
A: Yes, store the configuration in JSON format, then retrieve it from the database
   and pass it to the UpdateConfiguration() method of IConfigurationStore. If nothing
   changed then it will return immediately without doing anything.

Q: Can I make sure my configuration is valid before applying it to my application?
A: Yes, when you Initialize the ConfigurationStore, you can optionally pass an
   implementation of IConfigurationValidator. Your validator will only get called
   if the configuration changed, and if it returns 'false' then the configuration
   will not be applied.

Q: How can I see when there are errors in my configuration?
A: When you Initialize the ConfigurationStore, you can optionally pass an
   implementation of IErrorLogger. When you do this, all errors will be passed
   to your implementation so that you can report them any way you choose.

Q: I already use the ConfigurationManager and appSettings in my application's config
   file. Can I start using Urchin without migrating all my code or duplicating my
   configuration?
A: Yes, but this is a short-term stop gap. Right now if you go this route, all of
   your configuration will have to be maintained in appSettings until you have 
   migrated all of your code to Urchin.
   To do this, construct an instance of ConfigurationManagerSource and call it's 
   LoadConfiguration() method. Register for changes with the path /appSettings/name.
   For example if I have this in my web.config file:

       <appSettings>
	     <add key="cacheDuration" value="34"/>
       </appSettings>

   You can register for changes in cache duration with this code:

       private readonly IConfigurationStore _config;
       public void Initialize()
       {
	     _config.Register<int>("/appSettings/cacheDuration", CacheDurationChanged);
       }
	   public void CacheDurationChanged(int cacheDuration)
	   {
	   }

Q: Can I specify default values in my application so that I only need to configure
   things that are not the default value?
A: Yes, when you call the Register<T>() method of IConfigurationStore you can optionally
   pass a default value which will apply when there is no value specified in the
   configuration.