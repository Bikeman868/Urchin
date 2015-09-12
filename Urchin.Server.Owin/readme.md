# Urchin Server

## Installation
There is no installer application for the server yet. Please download the source code and compile
it using Visual Studio and the Dart SDK. To install the server you just need to copy a few files 
to the server and configure a web site in IIS.

### Development environment

To get going in development, you need to :

1. Download the [Dart SDK](https://www.dartlang.org/downloads/windows.html)
   and make sure the Dart SDK's `bin` folder is in your Windows environment path.
2. Open a command window and change the working directory to the `ui` folder
   in the `Urchin.Server.Owin` project.
3. Type `pub get` into the command prompt. This will download all the dependant
   packages from the Dart repository. This is similar to restoring packages in NuGet.
4. Type `pub build` into the command prompt. This will compile all the Dart
   code into JavaScript.
5. Open the solution in Visual Studio.
6. Change the config.txt file and set the persister file path.
7. Hit the run button and try these URLs:

   (http://localhost:60626/hello)[http://localhost:60626/hello]
   (http://localhost:60626/ui/index.html)[http://localhost:60626/ui/index.html]
   (http://localhost:60626/rules)[http://localhost:60626/rules]
   (http://localhost:60626/environments)[http://localhost:60626/environments]

> If you want to store your data in a database, then you must copy some files from the
> the `Urchin.Server.Persistence.Prius\bin\Release` folder. There is a commented out post build step 
> in this project that copies these files. Uncomment these steps
> before building if you want database persistence, or just copy the files manually.

> If you have problems running the UI under IIS make sure that the Dart packages folder is accessible
> to the IIS worker process. The Dart `pub` tool will create symbolic links in your solution
> folder that point to your roaming user profile, and by default IIS does not have access to this.

> If you want to set breakpoints and step through Dart code, then you wil need to install the
> Dartium browser. This is a version of Chrome with the Dart VM built into it. It cab run Dart
> code natively without compillation to JavaScript. When running the solution in Dartium, you can
> configure the server to serve .dart files to the browser by editing config.txt and changing the 
> setting for `/urchin/server/ui/physicalPath` from `~/ui/build/web` to `~/ui/web`.

### Production environment

These are the steps to making a production build:

1. Download the source code from GitHub (required).
2. Compile the Visual Studio solution (required).
3. Compile the Dart code to JavaScript (required for the management UI).
4. Copy the files to a folder on your web server (required).
5. Copy dlls from Urchin.Server.Persistence.Prius (required for database persistence).
6. Configure a new web site in IIS to point to the new folder (required).
7. Alter web.config and config.txt files to match your system (required).

#### Downloading the source code from GitHub

The source code is available at https://github.com/Bikeman868/Urchin. You can download it using any
Git client, or just click the download button on the GitHub page.

#### Compiling in Visual Studio

The solution was developed on Visual Studio 2013, but newer versions will also work. You can download
the community edition of Visual Studio from here https://www.visualstudio.com/.

You should ensure that the environment is set to 'Release' before building the solution.

#### Compile Dart code

Dart is a rich object oriented language that allows developers to create sophiticated client-side
experience in all existing browsers. The Dart language runs natively in some browsers, and can be
compiled into JavaScript to support older ones.

The managemnt UI is written in Dart. All of the Dart code is included in the Visual Studio
solution, but Visual Studio doesn't know how to compileit. If you want to use the
management UI, you need to download the [Dart SDK](https://www.dartlang.org/downloads/windows.html) and 
use the [Pub tool](https://www.dartlang.org/tools/pub/) to pull the dependant packages, and compile 
the Dart code into JavaScript.

Install the Dart SDK then open a command window and change the working directory to the `ui` folder
in the solution (where the `pubspec.yaml` file is) and run these Dart SDK commands:

    pub get
	pub build

#### Copy files to your web server

For the main server, copy:

| From | To |
| ------- | -------- |
| web.config | web.config |
| config.txt | config.txt |
| bin\\*.dll | bin\\*.dll |

For the optional management UI, copy:

| From | To |
| ------- | -------- |
| ui\\build\\web | ui |

For the optional database persistence, copy:

| From | To |
| ------- | -------- |
| Urchin.Server.Persistence.Prius\\bin\\Release\\Urchin.Server.Persistence.Prius.dll | bin\\Urchin.Server.Persistence.Prius.dll |
| Urchin.Server.Persistence.Prius\\bin\\Release\\MySql.Data.dll      | bin\\MySql.Data.dll |
| Urchin.Server.Persistence.Prius\\bin\\Release\\Npgsql.dll          | bin\\Npgsql.dll |
| Urchin.Server.Persistence.Prius\\bin\\Release\\Prius.Contracts.dll | bin\\Prius.Contracts.dll |
| Urchin.Server.Persistence.Prius\\bin\\Release\\Prius.Orm.dll       | bin\\Prius.Orm.dll |

#### Customize web.config and config.txt

You will need to edit the web.config and config.txt and adjust them to suit your production environment.
In the simplest scenario where rules are stored in a file, you just need to specify the location
of this file, and make sure that IIS can overwrite its contents.

You also need to change the `/urchin/server/ui/physicalPath` from  to `~/ui/web` development. The 
default value is `~/ui/build/web`, and you need to change it to `~/ui` for production.

Detailed configuration instructions follow.

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

## The management UI

If you chose to deploy the managemnt UI, then you can navigate to http://urchin.local/ui and 
you should be presented with a user interface that allows you to view, test and save 
environments and rules.

See the project status in the main readme for a description of what is currently possible in the 
management UI.

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

If you are using the Urchin client and server together, you should configure the Urchin client to 
GET its configuration from this endpoint.

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

| Method | Relative URL            | Query string | Example URL                                 |
| ------ | ----------------------- |------------- | ------------------------------------------- |
| GET    | /versions               |              | http://localhost/urchin/versions            |
| DELETE | /versions               |              | http://localhost/urchin/versions            |
| PUT    | /version/{version}      |              | http://localhost/urchin/version/12          |
| DELETE | /version/{version}      |              | http://localhost/urchin/version/12          |
| GET    | /rules/{version}        |              | http://localhost/urchin/rules/2             |
| GET    | /rules                  |              | http://localhost/urchin/rules               |
| POST   | /rules/{version}        |              | http://localhost/urchin/rules/1             |
| PUT    | /rules/{version}        |              | http://localhost/urchin/rules/3             |
| GET    | /rule/{version}/{name}  |              | http://localhost/urchin/rule/1/rule1        |
| PUT    | /rule/{version}/{name}  |              | http://localhost/urchin/rule/5/rule1        |
| POST   | /rule/{version}         |              | http://localhost/urchin/rule/1              |
| DELETE | /rule/{version}/{name}  |              | http://localhost/urchin/rule/3/rule1        |
| GET    | /environments           |              | http://localhost/urchin/environments        |
| PUT    | /environments           |              | http://localhost/urchin/environments        |
| GET    | /environment/default    |              | http://localhost/urchin/environment/default |
| PUT    | /environment/default    |              | http://localhost/urchin/environment/default |
| GET    | /rulenames/{version}    |              | http://localhost/urchin/ruledata            |
| POST   | /test/{version}         | machine, application, environment, instance | http://localhost/urchin/test?machine=mymachine&application=testapp |


#### The `/versions` Endpoint
GET this endpoint to retrieve a list of versions on the server. Each version has a sequential
version number and a name.

When you GET /rules and do not provide a version number, the most recent version of the rules
are returned. It is assumed that you are retrieving the rules for editing, so it the most recent
version is assigned to an environment, a new version is created which is a copy of the most recent
version. This is the only way that new versions get created.

DELETE this endpoint to remove all old versions. The versions that will be deleted are the ones
whose version number is less than the lowest version number assigned to an environment. For example
is version 9 is in production, version 11 in staging and version 16 in development, then the draft
version for editing will be version 17, and calling DELETE on the `/versions' endpoint will delete
all versions prior to version 9.

#### The `/version/{version}` Endpoint
PUT this endpoint to change the name of a version. Only the name can be changed, the version
numbers are sequential from 1 and can not be changed.

DELETE this endpoint to remove a specific version from the server. If this version is currently
assigned to an environment then an error will be returmed.

#### The `/rules` Endpoint
GET this endpoint to retrieve a list of the rules. The returned JSON includes the name of the rule,
the conditions under which this rule applies.

When you GET this endpoint, you can optionally specify a version number. If you specify a version
number, this is the verson of the rules that will be returned. If you do not specify a version
number, then a draft version of the rules are returned. The draft version will have the highest
version number, and will not be in use in any environment. If the current highest version number
is assigned to an environment, then this version will be copied to create a new draft version.

POST this endpoint to completely replace the current rules. The version number must be
provided. The format of the POST body is identical to the response you GET from this endpoint. 
Rule names must be unique. Each rule can include a set of conditions in which that rule applies.
You can not supply the valiables and config data for each rule with this endpoint. Set these 
details by doing PUT to the `/rule/{version}/{name}` endpoint.

PUT this endpoint to update one or more existing rules. This endpoint does not allow you to change
the name of the rule. If you want to rename a rule, PUT the `/rule/{version}/{name}` endpoint
instead.

#### The `/rule/{version}/{name}` Endpoint
GET this endpoint to retrieve the full details of an individual rule by name and version.

PUT this endpoint to update a rule by name and version, or to rename a rule. An error is 
returned if the rule does not exist. The format of the request body is identical to the 
response you receive from GET. The name in the URL should be the name of an existing rule to 
replace. The name passed in the body of the request should be the new name of the rule.

DELETE this endpoint to remove a rule from the server.

POST to this endpoint to create a new rule. The format of the request body is identical to the 
response you receive from GET. Note that in this case the name of an existing rule is not required
in the URL. If a rule with this name already exists you will get an error response.

#### The `/environments` Endpoint
When you GET this endpoint, the server returns a list of the environments, the machines in each
of those environments, the version number of the rules to apply to that environment, and the 
security restrictions for each environment.

When you PUT with the same format of data, all of the environment data on the server is overwritten
with whatever you PUT.

#### The `/environment/default` Endpoint
Allows you to GET and PUT the name of the environment to use for all machines that are not listed
in one of the environments. Note that this only applies if the client application does not supply
an environment when it requests configuration data.

#### The `/rulenames/{version}` Endpoint
Retrievs a list of all of the rules in a specific version. This allows you to retrieve the rule
details by making a GET request to `/rule/{version}/{name}` later.

#### The `/test/{version}` Endpoint
GET this endpoint to retrieve an application config for a specific version of the rules.

This allows you test a version of the rules before applying them to an environment, making them
live to application instances. When you GET the `/config` endpoint it will query the version
of rules that applies to that query by looking at the machine name and environment name passed
in the query. This endpoint gives you a way to test other versions of rules, not the one assigned
to the machine's environment.

If you omit the version number, then the current draft version of the rules will be tested.

## Recommended best practice for rule configuration
There are many ways you can organize your rules. If you are new to Urchin, I recommend you try this
first, and experiment later as needed.

My first recommendation is only put config into rules that specify the application. All of your 
rules that specify environmemt, machine and instance only should only set variables, then these
variables should be referenced in the application specific config.

> Note that examples shown below assume that you have installed the Urchin server with a host
> name of `urchin.local`. If your server is at a different URL you will need to adjust the URLs
> from these examples accordingly.

Lets work through an example of configuring the Prius ORM, where there are multiple applications
that each use a different but overlapping set of databases, and each database has a different
connection string in each environment.

For example if you `PUT` this JSON to the Urchin server at `http://urchin.local/rule/root`

    {
      "name": "Root",
      "variables": 
      [
        {name:"StandardFallbackPolicies", value:"{ name:\"noFallback\", allowedFailurePercent:100 }"},
        {name:"Repository1", value:"{ name:\"Repository1\", clusters:[{ databases:[\"Database1\"], fallbackPolicy:\"noFallback\" }]}"},
        {name:"Repository2", value:"{ name:\"Repository2\", clusters:[{ databases:[\"Database2\"], fallbackPolicy:\"noFallback\" }]}"}
      ]
    }

The Urchin server will create or overwrite a rule called 'Root' that will set three variables in all 
environments and for all applications, all machines and all instances. Note that just setting variables
like this does not put anything into the config file.

These variables define snippets of JSON that can be assembled into the application config later.

Our repositories are defined globally, but the database is different in each environment. We can
define the database variables in the development environment by `PUT` this JSON to `http://urchin.local/rule/development`

    {
      "name": "Development",
      "environment": "Development",
      "variables": 
      [
        {name:"Database1",  value:"{ name:\"Database1\", type:\"SqlServer\", connectionString:\"server=DEVDB; ......... \" }"},
        {name:"Database2",  value:"{ name:\"Database2\", type:\"SqlServer\", connectionString:\"server=DEVDB; ......... \" }"}
      ]
    }

This can be repeated for other environments, setting the appropriate connection strings for each database in
each environment.

Now we can define the config file for an application using the variables we already set in other rules. Here
is an example of an application that only uses database 1. Post this JSON to  `http://urchin.local/rule/application1`

    {
        name: "Application1",
        application: "Application1",
        config:"
        {
            prius:
            {
                databases:
                [
                    ($Database1$)
                ],
                fallbackPolicies:
                [
                    ($StandardFallbackPolicies$)
                ], 
                repositories:
                [
                    ($Repository1$)
                ]
            }
        }"
    }

And if application 2 uses both databases, it can be configured by a `PUT` to `http://urchin.local/rule/application2`
like this:

    {
        name: "Application2",
        application: "Application2",
        config:"
        {
            prius:
            {
                databases:
                [
                    ($Database1$),
                    ($Database2$)
                ],
                fallbackPolicies:
                [
                    ($StandardFallbackPolicies$)
                ], 
                repositories:
                [
                    ($Repository1$),
                    ($Repository2$)
                ]
            }
        }"
    }

Now if you `GET` from  `http://urchin.local/confi?machine=mymachine&application=application2&environment=development`
you will receive the following response:

    {
	    prius:
		{
		    databases:
			[
				{name:"Database1", type:"SqlServer", connectionString:" ......... " },
				{name:"Database2", type:"SqlServer", connectionString:" ......... " }
			],
			fallbackPolicies:
			[
				{name:"noFallback", allowedFailurePercent:100}
			],
			repositories:
			[
				{name:"Repository1", clusters:[{databases:["Database1"], fallbackPolicy:"noFallback"}]},
				{name:"Repository2", clusters:[{databases:["Database2"], fallbackPolicy:"noFallback"}]}
			]
		}
    }

Which is a complete and correct Prius configuration.

So what happens if we want the production environment to load balance across two database instances? No
problem, we just need to create a new rule for production, and since it is more specific than the 'Root'
rule that defines the repositories, it will override just for production, and all other environments will
be unaffected. You can make this change with a `PUT` to  `http://urchin.local/rule/production`

    {
      "name": "Production",
      "environment": "Production",
      "variables": 
      [
        {name:"Database1",  value:"
			{ name:\"Database1a\", type:\"SqlServer\", connectionString:\"server=PRODDB1; ......... \" },
			{ name:\"Database1b\", type:\"SqlServer\", connectionString:\"server=PRODDB2; ......... \" }
			"},
        {name:"Database2",  value:"
			{ name:\"Database2a\", type:\"SqlServer\", connectionString:\"server=PRODDB1; ......... \" },
			{ name:\"Database2b\", type:\"SqlServer\", connectionString:\"server=PRODDB2; ......... \" }
			"},
        {name:"Repository1", value:"{ name:\"Repository1\", clusters:[{ databases:[\"Database1a\",\"Database1b\"], fallbackPolicy:\"noFallback\" }]}"},
        {name:"Repository2", value:"{ name:\"Repository2\", clusters:[{ databases:[\"Database2a\",\"Database2b\"], fallbackPolicy:\"noFallback\" }]}"}
      ]
    }

Now if you `GET` from  `http://urchin.local/confi?machine=mymachine&application=application2&environment=development`
you will still receive the following response:

    {
	    prius:
		{
		    databases:
			[
				{name:"Database1", type:"SqlServer", connectionString:" ......... " },
				{name:"Database2", type:"SqlServer", connectionString:" ......... " }
			],
			fallbackPolicies:
			[
				{name:"noFallback", allowedFailurePercent:100}
			],
			repositories:
			[
				{name:"Repository1", clusters:[{databases:["Database1"], fallbackPolicy:"noFallback"}]},
				{name:"Repository2", clusters:[{databases:["Database2"], fallbackPolicy:"noFallback"}]}
			]
		}
    }

But if you `GET` from  `http://urchin.local/confi?machine=mymachine&application=application2&environment=production`
you will receive the this instead:

    {
	    prius:
		{
		    databases:
			[
				{name:"Database1a", type:"SqlServer", connectionString:" ......... " },
				{name:"Database1b", type:"SqlServer", connectionString:" ......... " },
				{name:"Database2a", type:"SqlServer", connectionString:" ......... " },
				{name:"Database2b", type:"SqlServer", connectionString:" ......... " }
			],
			fallbackPolicies:
			[
				{name:"noFallback", allowedFailurePercent:100}
			],
			repositories:
			[
				{name:"Repository1", clusters:[{databases:["Database1a","Database1b"], fallbackPolicy:"noFallback"}]},
				{name:"Repository2", clusters:[{databases:["Database2a","Database2b"], fallbackPolicy:"noFallback"}]}
			]
		}
    }

