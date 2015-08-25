# Urchin Server

## Installation
There is no installer application for the server yet. Please download the source code and compile
it using Visual Studio. To install the server you just need to copy a few files to the server and
configure a web site in IIS.

To build the server, compile the Urchin.Server.Owin project. If you want to store your data in a
database, then you should also compile Urchin.Server.Persistence.Prius.

In development, you can create a web site in IIS and point it to Urchin.Server.Owin project folder,
or you can run this project from within Visual Studio by right clicking and choosing Debug|Start new 
instance.

To deploy to production, make sure you build the 'Release' version, then deploy:
  web.config
  config.txt
  bin\*.dll

If you want to store your data in a database, then you must also copy some files from the
the Urchin.Server.Persistence.Prius\bin folder. There is a commented out post build step 
in this project that copies these files to Urchin.Server.Owin\bin. Uncomment these steps
before building if you want database persistence.

## Configuration
The Urchin server uses the Urchin client to manage its configuration file - nothing like eating
your own dog food. The configuration is stored in the config.txt file.

If you are using the default file persister, then you should configure the location of the rules
file in config.txt. Note that this file is in JSON format, and directory separators are reserved
characters in JSON and must be escaped.

If you are using the Prius persister, then you need to configure the name of the Prius repository
to use, and you also need to configure Prius - since it also uses Urchin Client for its configuration.

This server uses the following configurable modules:

### Owin
Not much configuration you can do here.

### Common.Logging Package
This NuGet package is used for logging. You can configure it via the web.config file. See 
[documentation](http://netcommon.sourceforge.net/documentation.html) for the available configuration options.

### Prius Package
This NuGet package is used for database persistence, and is optional. If you are using it, then
you need to configure it in the config.txt file. The config.txt file already contains a boilerplate
configuration for MySQL, you need just need to customize the connection string for the location
and logon credentials of your MySQL instance.

If you want to persist to another database (Microsoft SQL Server for example), then take a look at
the [Prius documentation](https://github.com/Bikeman868/Prius) for configuration details.

## Testing
Once you have your server installed and configured, you can check if it's working using a browser.
Assuming you a new web site in IIS with the host name of 'urchin.local', then you can browse
to http://urchin.local/hello and the server should reply back with a hello message. You can
use this endpoint in your system health checks.

If you want to perform more in-depth testing, I recommend a Chrome app called Postman. You will find
a file called 'Urchin.json.postman_collection' in the source code that can be imported into
Postman. This will provide example calls for all methods available in the API that you can test
using Postman.

## REST API
This server has a RESTful API with JSON in the body of POSTs and PUTs and it replies with JSON.
The sections below define the endpoints, each endpoint definition specifies the HTTP method
which is either GET, PUT, POST or DELETE.

If you make a GET request to the server with a URL it will return the data identified by that 
URL. If you make a PUT request with the exact same URL then this data will be overriden. The
format of the body of the PUT is exactly the same as the response from GET. If you make a
DELETE request to the same URL it will delete this data from the server.

New records can be created on the server by making a POST request and including the data to
add in the body of the request.

If you want to experiment with the API, my personal favorite tool is Postman, which is a
Google Chrome extension. This is the tool I used to debug Urchin Server.

### Client Configuration REST Interface
Client applications should call this endpoint to obtain their configuration data.

| Method | Relative URL | Query string | Example URL |
| ------ | ------------ |------------- | ----------- |
| GET    | /config      | machine, application, environment, instance | http://localhost/urchin/config?machine=mymachine&application=testapp |
| GET    | /trace       | machine, application, environment, instance | http://localhost/urchin/trace?machine=mymachine&application=testapp |
| GET    | /hello       |              | http://localhost/urchin/trace?machine=mymachine&application=testapp |

#### The `/config` Endpoint
When you GET this endpoint, it returns JSON document defining the configuration for an instance 
of application running on a specific machine in a specific environment.

If you are using the Urchin client and server together, you should point the Urchin client to 
this endpoint on the server.

The query string parameters are:

| Parameter   | Required  | Description |
| ----------- | --------- |------------ |
| machine     | required  | The name of the computer running the application. Can be obtained from System.Environment.MachineName |
| application | required  | The name of the application. You can use the executable file name or any naming convention you choose |
| environment | optional  | The name of the environment, for example development, staging, integration, prod. If this parameter is not provided, the environment will be determined from the machine name |
| instance    | optional  | If you have multiple instances of the same application running on one machine, you can use this parameter to send them different configuration data |

#### The `/trace` endpoint
When you GET this endpoint, it performs the same operation as GET on /config, but instead of returning
just the config, it also returns data that shows which rules were applied and which rules were overriden
by other higher precedence rules. This is designed to help to debug issues with rule sets that do not
return the configuration data you wanted.

#### The `/hello` Endpoint
When you GET this endpoint the Urchin server will return a hello message. This is useful for making sure 
the server is running, and reachable over the network. You can also use this in health check monitors.

### Rule Management REST Interface
These endpoints are used by the management UI to allow the server configuration to be configured.
You can also use these endpoints in your own software to query or modify the rules data.

| Method | Relative URL  | Query string | Example URL |
| ------ | ------------- |------------- | ----------- |
| GET    | /rules        |              | http://localhost/urchin/rules |
| POST   | /rules        |              | http://localhost/urchin/rules |
| PUT    | /rules        |              | http://localhost/urchin/rules |
| GET    | /rule/{name}  |              | http://localhost/urchin/rule/rule1 |
| PUT    | /rule/{name}  |              | http://localhost/urchin/rule/rule1 |
| POST   | /rule         |              | http://localhost/urchin/rule |
| DELETE | /rule/{name}  |              | http://localhost/urchin/rule/rule1 |
| GET    | /environments |              | http://localhost/urchin/environments |
| PUT    | /environments |              | http://localhost/urchin/environments |
| GET    | /environment/default |       | http://localhost/urchin/environment/default |
| PUT    | /environment/default |       | http://localhost/urchin/environment/default |
| GET    | /ruledata     |              | http://localhost/urchin/ruledata |
| POST   | /test         | machine, application, environment, instance | http://localhost/urchin/test?machine=mymachine&application=testapp |


#### The `/rules` Endpoint
GET this endpoint to retrieve a list of the rules. The returned JSON includes the name of the rule
and the conditions under which this rule applies.

POST this endpoint to create a new set of rules. The format of the POST body is identical to the
response you GET from this endpoint. Rule names must be unique. Each rule can include a set of
conditions in which that rule applies. You can not supply the valiables and config data for each 
rule with this endpoint. Set these details by doing PUT to the `/rule/{name}` endpoint.

PUT this endpoint to update one or more existing rules. This endpoint does not allow you to change
the name of the rule. If you want to rename a rule, PUT the `/rule/{name}` endpoint instead.

#### The `/rule` Endpoint
GET this endpoint to retrieve the full details of an individual rule by name.

PUT this endpoint to update a rule by name, or to rename a rule. An error is returned if the
rule does not exist. The format of the request body is identical to the response you receive from GET.
The name in the URL should be the name of an existing rule to replace. The name passed in the body
of the request should be the new name of the rule.

DELETE this endpoint to remove a rule from the server.

POST to this endpoint to create a new rule. The format of the request body is identical to the 
response you receive from GET. Note that in this case the name of an existing rule is not required
in the URL. If a rule with this name already exists you will get an error response.

#### The `/environments` Endpoint
When you GET this endpoint, the server returns a list of the environments, and the machines in each
of those environments.

When you PUT with the same format of data, all of the environment data on the server is overwritten
with whatever you PUT.

#### The `/environment/default` Endpoint
Allows you to GET and PUT the name of the environment to use for all machines that are not listed
in one of the environments. Note that this only applies if the client application does not supply
an environment when it requests configuration data.

#### The `/ruledata` Endpoint
Retrievs the entire rule database from the server. This allows you to modify it and pass it to the
`/test` endpoint to test your changes before commiting them to the server.

#### The `/test` Endpoint
This allows you to post an entire rule database with all environments and rules plus a query, and
test what the query would return if you POSTed this data to the server. This provides a way
to GET the `/ruledata` then edit and test changes before finally POSTing the new rules back to the
server.