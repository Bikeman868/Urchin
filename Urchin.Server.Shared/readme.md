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
* Configuration data can be decrypted using an application provided implementation.
* Migration path from exiting .Net ConfigurationManager implementation.

## Server Features
* Rules based configuration based on environment, machine, application and instance.
* Centralized configuration management with REST API and configuration mananagement UI.
* Urchin Client can pull config by polling the server at a URL that includes query
  string parameters to specify machine, application, environment and instance.
* Rules for determining environment from machine so that this is an optional parameter.
* Variable declaration and substitution.
* The integrator can add an assembly to the `bin` folder to provide a custom encryption
  of the configuration data that is sent to the client.

## Urchin.Server.Shared Assembly
This assembly is used by Urchin.Server.Owin, which is a self contained Urchin web service.
If you just want to deploy an Urchin server to support your Urchin clients, then you should
download Urchin solution from GitHub at https://github.com/Bikeman868/Urchin and compile
the Urchin.Server.Owin solution.

If you are looking to build your own Urchin server, or build Urchin endpoints into an
existing web service, then this package is for you, read on...

## How to get started
The best way to see how to build an Urchin server is to look at the source code for the
Urchin server! It's available on GitHub, so go check it out. The only part you need to
support the Urchin client is the `/config` endpoint, which is defined by the source file
`Urchin.Server.Owin\Middleware\ConfigEndpoint.cs`. This file contains very little code
because most of the functionallity of the server is contained in Urchin.Server.Shared
which is great, because you don't have much to do!
