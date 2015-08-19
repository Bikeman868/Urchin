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

#### The /config Endpoint
Returns JSON document defining the configuration for an instance of application running on a 
specific machine in a specific environment.

If you are using the Urchin client and server together, you should point the Urchin client to 
this endpoint on the server.

The query string parameters are:

| Parameter   | Required  | Description |
| ----------- | --------- |------------ |
| machine     | required  | The name of the computer running the application. Can be obtained from System.Environment.MachineName |
| application | required  | The name of the application. You can use the executable file name or any naming convention you choose |
| environment | optional  | The name of the environment, for example development, staging, integration, prod. If this parameter is not provided, the environment will be determined from the machine name |
| instance    | optional  | If you have multiple instances of the same application running on one machine, you can use this parameter to send them different configuration data |

### Rule Management REST Interface
These endpoints are used by the management UI to allow the server configuration to be configured.
You can also use these endpoints in your own software to query or modify the rules data.

| Method | Relative URL | Query string | Example URL |
| ------ | ------------ |------------- | ----------- |
| GET    | /rules       |              | http://localhost/urchin/rules |

