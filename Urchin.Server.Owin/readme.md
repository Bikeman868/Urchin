# Urchin Server

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
| GET    | /rule/{name}  |              | http://localhost/urchin/rule/rule1 |
| PUT    | /rule/{name}  |              | http://localhost/urchin/rule/rule1 |
| POST   | /rule/{name}  |              | http://localhost/urchin/rule/rule1 |
| DELETE | /rule/{name}  |              | http://localhost/urchin/rule/rule1 |
| GET    | /environments |              | http://localhost/urchin/environments |
| PUT    | /environments |              | http://localhost/urchin/environments |
| GET    | /environment/default |       | http://localhost/urchin/environment/default |
| PUT    | /environment/default |       | http://localhost/urchin/environment/default |

#### The `/rules` Endpoint
GET this endpoint to retrieve a list of the rules. The returned JSON includes the name of the rule
and the conditions under which this rule applies.

POST this endpoint to create a new set of rules. The format of the POST body is identical to the
response you GET from this endpoint. Rule names must be unique. Each rule can include a set of
conditions in which that rule applies. You can not supply the valiables and config data for each 
rule with this endpoint. Set these details by doing PUT to the `/rule` endpoint.

#### The `/rule` Endpoint
GET this endpoint to retrieve the full details of an individual rule by name.

PUT this endpoint to update a rule by name. An error is returned if the rule does not exist. The
format of the request body is identical to the response you receive from GET.

DELETE this endpoint to remove a rule from the server.

POST to this endpoint to create a new rule. The format of the request body is identical to the 
response you receive from GET.

#### The `/environments` Endpoint
When you GET this endpoint, the server returns a list of the environments, and the machines in each
of those environments.

When you PUT with the same format of data, all of the environment data on the server is overwritten
with whatever you PUT.

#### The `/environment/default` Endpoint
Allows you to GET and PUT the name of the environment to use for all machines that are not listed
in one of the environments. Note that this only applies if the client application does not supply
an environment when it requests configuration data.
