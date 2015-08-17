Urchin
======
A rules based centralized enterprise configuration management solution for .Net

Urchin.Client         Add this to your application to get access to configuration data.
Urchin.Server.Owin    Install this on IIS to provide rules based cenrtalized configuration repository.

FAQ
===

Q: Do I need to use the server component?
A: No, you can use the client with a configuration file, or and URI that returns the configuration data.

Q: How do I get started?
A: The simplest steps to a working solution are:
   1. Install the NuGet package for Urchin.Client.
   2. Register a mapping in your favorite IoC for IConfigurationStore to ConfigurationStore as a singleton.
   3. Create a configuration file in JSON format.
   4. Construct an instance of Urchin.Client.Sources.FileSource and initialize it with the location of your file.
      You will have to pass IConfigurationStore to the constructor - you can let IoC do this for you.
	  You need to keep a reference to FileSource for it to notice config changes.
	  When you dispose of the FileSource it will stop watching the configuration file for changes.
   5. Inject IConfigurationStore into your classes that need to be notified of configuration changes.
   6. Call the Register<T>() method of IConfigurationStore to get notified when config changes.

Q: What's the best way to see how to use the client?
A: Take a look at the unit tests for ConfigurationStore in Urchin.Client.Tests

Q: How do I know what path to use when I register with IConfigurationStore?
A: The path parameter is the path to a node in the JSON configuration file.
   Use / separators to go move from a JSON object to one of its properties.
   For example in this JSON {section1:{value1:23,value2:87},section2:{}}
   A path of /section1/value1 refers to the number 23.

Q: Do I have to register for each configuration value in my JSON?
A: No, you can register for notifications at any level of the configuration heirachy.
   When you register a JSON object, suppy a .Net class type that can be deserialized from this JSON object.
   For example if you have this JSON configuration {section1:{value1:23,value2:87},section2:{value1:19,value2:43}}
   You can write a C# class like this:
       public class SectionConfig
	   {
	     public int Value1 { get; set; }
	     public int Value2 { get; set; }
	   }
	Then you can register with the IConfigurationStore like this:
		public void Initialize()
		{
			_configurationStore.Register<SectionConfig>("/section1", Section1Changed);
			_configurationStore.Register<SectionConfig>("/section2", Section2Changed);
		}
		private void Section1Changed(SectionConfig section1)
		{
		}
		private void Section2Changed(SectionConfig section2)
		{
		}