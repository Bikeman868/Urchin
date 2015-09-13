import 'dart:html';
import 'dart:async';

class Server
{
//
//-- Version related server methods -----------------------------------------------------------------
//
	static Future<List<VersionDto>> getVersions() async
	{
		String response = await HttpRequest.getString('/versions');
		List<Map> mapList = JSON.decode(response);

		var versions = new List<RuleVersion>();
		for (Map v in mapList)
		{
			versions.add(new VersionDto(v));
		}
		return versions;
	}

	static Future<HttpRequest> deleteOldVersions()
		=> HttpRequest.request(
			'/versions', 
			method: 'DELETE');

	static Future<HttpRequest> updateVersion(int version, VersionDto versionDto)  async
		=> HttpRequest.request(
			'/version/' + version, 
			method: 'PUT',
			sendData: JSON.encode(versionDto),
			mimeType: 'application/json');
  
	static Future<HttpRequest> deleteVersion(int version)
		=> HttpRequest.request(
			'/version/' + version, 
			method: 'DELETE');
//
//-- Rule related server methods -------------------------------------------------------------------
//
	static Future<List<String>> getRuleNames(int version) async
	{
		String response = await HttpRequest.getString('/rulenames/' + version );
		List<Map> rules = JSON.decode(response);

		var ruleNames = new List<String>();
		for (Map r in rules)
		{
			ruleNames.add(r['name']);
		}
		return ruleNames;
	}
  
	static Future<Map<String, RuleDto>> getRules(int version)  async
	{
		String response = await HttpRequest.getString('/rules/' + version);
		List<Map> rules = JSON.decode(response);

		var rules = new Map<String, RuleDto>();
		for (Map r in rules)
		{
			rules.add(r['name'], new RuleDto(r));
		}
		return rules;
	}

	static Future<Map<String, RuleDto>> getDraftRules() async
	{
		String response = await HttpRequest.getString('/rules');
		List<Map> rules = JSON.decode(response);

		var rules = new Map<String, RuleDto>();
		for (Map r in rules)
		{
			rules.add(r['name'], new RuleDto(r));
		}
		return rules;
	}

	static Future<HttpRequest> addRules(int version, List<RuleDto> rules) 
		=> HttpRequest.request(
			'/rules/' + version, 
			method: 'POST',
			sendData: JSON.encode(rules),
			mimeType: 'application/json');

	static Future<HttpRequest> updateRules(int version, List<RuleDto> rules) 
		=> HttpRequest.request(
			'/rules/' + version, 
			method: 'PUT',
			sendData: JSON.encode(rules),
			mimeType: 'application/json');

	static Future<String> getRule(int version, String ruleName) 
		=> HttpRequest.getString(
			'/rule/' + version + '/' + ruleName);

	static Future<HttpRequest> updateRenameRule(int version, String oldName, RuleDto rule) 
		=> HttpRequest.request(
			'/rule/' + version + '/' + oldName, 
			method: 'PUT',
			sendData: JSON.encode(rule),
			mimeType: 'application/json');

	static Future<HttpRequest> addRule(int version, RuleDto rule) 
		=> HttpRequest.request(
			'/rule/' + version, 
			method: 'POST',
			sendData: JSON.encode(rule),
			mimeType: 'application/json');

	static Future<String> deleteRule(int version, String ruleName) 
		=> HttpRequest.request(
			'/rule/' + version + '/' + ruleName, 
			method: 'DELETE');
//
//-- Environment ------------------------------------------------------------------------------
//
	static Future<Map<String, EnvironmentDto>> getEnvironments() async
	{
		HttpRequest request = await HttpRequest.getString('/environments');
		List<Map> environmentList = JSON.decode(request);

		var environments = new Map<String, EnvironmentDto>();
		for (Map environment in environmentList)
		{
			environments[environment['name']] = new EnvironmentDto(environment);
		}
		return environments;
	}

	static Future<String> replaceEnvironments(List<EnvironmentDto> environments)
		=> HttpRequest.request(
			'/environments',
			method: 'PUT',
			sendData: JSON.encode(environments),
			mimeType: 'application/json');

	static Future<String> getDefaultEnvironment()
		=> HttpRequest.getString('/environment/default');

	static Future<String> setDefaultEnvironment(String environmentName)
		=> HttpRequest.request(
			'/environment/default',
			method: 'PUT',
			sendData: '"' + environmentName + '"',
			mimeType: 'application/json');

//
//-- Application config related server methods --------------------------------------------------
//
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

	static Future<String> traceConfig(String machine, String application, String environment, String instance) async
	{
		if (machine == null || machine.isEmpty)
			throw 'Machine name can not be empty';
		
		if (application == null || application.isEmpty)
			throw 'Application name can not be empty';

		var url = '/trace?machine=' + machine + '&application=' + application;

		if (environment != null && !environment.isEmpty)
			url = url + '&environment=' + environment;

		if (instance != null && !instance.isEmpty)
			url = url + '&instance=' + instance;

		return HttpRequest.getString(url);
	}

	static Future<String> testConfig(int version, String machine, String application, String environment, String instance) async
	{
		if (machine == null || machine.isEmpty)
			throw 'Machine name can not be empty';
		
		if (application == null || application.isEmpty)
			throw 'Application name can not be empty';

		var url = '/test/' + version + '?machine=' + machine + '&application=' + application;

		if (environment != null && !environment.isEmpty)
			url = url + '&environment=' + environment;

		if (instance != null && !instance.isEmpty)
			url = url + '&instance=' + instance;

		return HttpRequest.getString(url);
	}

//
//-- Logon related server methods ------------------------------------------------------------------------------
//
	static Future<String> getLoggedOnUser()
		=> HttpRequest.getString(
			'/user');

	static Future<HttpRequest> logon(String userName, String password)
		=> HttpRequest.request(
			'/logon', 
			method: 'POST',
			sendData: '{"username": "' + userName + '","password": "' + password + '"}',
			mimeType: 'application/json',
			responseType: 'application/json');

	static Future<HttpRequest> logoff()
		=> HttpRequest.request(
			'/logoff',
			method: 'POST');
}
