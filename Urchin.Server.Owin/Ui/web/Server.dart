import 'dart:html';
import 'dart:async';

class Server
{
	static Future<String> getRule(String ruleName) 
		=> HttpRequest.getString('/rule/' + ruleName);
  
	static Future<String> getRules() 
		=> HttpRequest.getString('/rules');

	static Future<String> getEnvironments()
		=> HttpRequest.getString('/environments');

	static Future<String> getConfig(String machine, String application, String environment, String instance) async
	{
		if (machine == null || machine.isEmpty)
			throw 'Machine name can not be empty';
		
		if (application == null || application.isEmpty)
			throw 'Application name can not be empty';

		var url = '/config?machine=' + machine + '&application=' + application;

		if (environment != null && !environment.isEmpty)
			url = url + '&environment=' + environment;

		if (instance != null && !instance.isEmpty)
			url = url + '&instance=' + instance;

		return HttpRequest.getString(url);
	}

	static Future<String> getLoggedOnUser()
		=> HttpRequest.getString('/user');
}

class _Server
{
	static Future<String> getRule(String ruleName) async 
		=> '{"name":"' + ruleName + '","machine":"MyMachine"}';
  
	static Future<String> getRules() async 
		=> '[{"name":"Rule 1"},{"name":"Rule 2"}]';

	static Future<String> getEnvironments() async
		=> '[{"name":"Production","machines":["web1","web2"]},{"name":"Staging","machines":["stg1","stg2"]}]';

	static Future<String> getConfig(String machine, String application, String environment, String instance) async
		=> '{"app":{[{"name":"value"}]}}'

	static Future<String> getLoggedOnUser() async
		=> 'TestUser';
}
