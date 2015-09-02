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
}

class _Server
{
	static Future<String> getRule(String ruleName) async 
		=> '{"name":"' + ruleName + '","machine":"MyMachine"}';
  
	static Future<String> getRules() async 
		=> '[{"name":"Rule 1"},{"name":"Rule 2"}]';

	static Future<String> getEnvironments() async
		=> '[{"name":"Production","machines":["web1","web2"]},{"name":"Staging","machines":["stg1","stg2"]}]';
}
