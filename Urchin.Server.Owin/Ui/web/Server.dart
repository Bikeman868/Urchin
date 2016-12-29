import 'dart:html';
import 'dart:async';
import 'dart:convert';

import 'Models/ClientCredentialsModel.dart';
import 'Models/EnvironmentModel.dart';
import 'Models/PostResponseModel.dart';
import 'Models/RuleModel.dart';
import 'Models/VersionModel.dart';
import 'Models/VersionNameModel.dart';
import 'Models/SecurityRuleModel.dart';
import 'Models/VariableModel.dart';

class Server
{
//
//-- Version related server methods -----------------------------------------------------------------
//
	static Future<List<VersionModel>> getVersions() async
	{
		String response = await HttpRequest.getString('/versions');
		List<Map> versionsJson = JSON.decode(response);

		var versions = new List<VersionModel>();
		for (Map versionJson in versionsJson)
		{
			versions.add(new VersionModel(versionJson, false));
		}
		return versions;
	}

	static Future<PostResponseModel> deleteOldVersions() async
	{
		var request = await HttpRequest.request(
			'/versions', 
			method: 'DELETE');

		if (request.status != 200)
			throw 'Failed to delete old versions. ' + request.statusText;

		Map json = JSON.decode(request.responseText);
		return new PostResponseModel(json);
	}

	static Future<PostResponseModel> updateVersion(int version, VersionModel versionDto) async
	{
		var versionName = new VersionNameModel(null);
		versionName.name = versionDto.name;
		versionName.version = versionDto.version;

		var request = await HttpRequest.request(
			'/version/' + version.toString(), 
			method: 'PUT',
			sendData: JSON.encode(versionName.json),
			mimeType: 'application/json');

		if (request.status != 200)
			throw 'Failed to update version ' + version.toString() + '. ' + request.statusText;

		Map json = JSON.decode(request.responseText);
		return new PostResponseModel(json);
	}
  
	static Future<PostResponseModel> deleteVersion(int version) async
	{
		var request = await HttpRequest.request(
			'/version/' + version.toString(), 
			method: 'DELETE');

		if (request.status != 200)
			throw 'Failed to delete version ' + version.toString() + '. ' + request.statusText;

		Map json = JSON.decode(request.responseText);
		return new PostResponseModel(json);
	}
//
//-- Rule related server methods -------------------------------------------------------------------
//
	static Future<List<String>> getRuleNames(int version) async
	{
		String response = await HttpRequest.getString('/rulenames/' + version.toString() );
		return JSON.decode(response);
	}
  
	static Future<List<String>> getDraftRuleNames() async
	{
		String response = await HttpRequest.getString('/rulenames');
		return JSON.decode(response);
	}
  
	static Future<VersionModel> getRules(int version)  async
	{
		String response = await HttpRequest.getString('/rules/' + version.toString());
		return new VersionModel(JSON.decode(response), true);
	}

	static Future<VersionModel> getDraftRules() async
	{
		String response = await HttpRequest.getString('/rules');
		return new VersionModel(JSON.decode(response), true);
	}

	static Future<PostResponseModel> addRules(int version, List<RuleModel> rules) async
	{
		var requestBody = rules.map((RuleModel m) => m.json).toList();
		var request = await HttpRequest.request(
			'/rules/' + version.toString(), 
			method: 'POST',
			sendData: JSON.encode(requestBody),
			mimeType: 'application/json');

		if (request.status != 200)
			throw 'Failed to add rules. ' + request.statusText;

		Map json = JSON.decode(request.responseText);
		return new PostResponseModel(json);
	}

	static Future<PostResponseModel> updateRules(int version, List<RuleModel> rules) async
	{
		var requestBody = rules.map((RuleModel m) => m.json).toList();
		var request = await HttpRequest.request(
			'/rules/' + version.toString(), 
			method: 'PUT',
			sendData: JSON.encode(requestBody),
			mimeType: 'application/json');

		if (request.status != 200)
			throw 'Failed to update rules. ' + request.statusText;

		Map json = JSON.decode(request.responseText);
		return new PostResponseModel(json);
	}

	static Future<RuleModel> getRule(int version, String ruleName) async
	{
		String response = await HttpRequest.getString('/rule/' + version.toString() + '/' + ruleName);
		return new RuleModel(JSON.decode(response));
	}

	static Future<PostResponseModel> updateRenameRule(int version, String oldName, RuleModel rule) async
	{
		var request = await HttpRequest.request(
			'/rule/' + version.toString() + '/' + oldName, 
			method: 'PUT',
			sendData: JSON.encode(rule.json),
			mimeType: 'application/json');

		if (request.status != 200)
			throw 'Failed to rename version ' + version.toString() + ' of ' 
				+ oldName + ' to ' + rule.name + '. ' + request.statusText;

		Map json = JSON.decode(request.responseText);
		return new PostResponseModel(json);
	}

	static Future<PostResponseModel> addRule(int version, RuleModel rule) async
	{
		var request = await HttpRequest.request(
			'/rule/' + version.toString(), 
			method: 'POST',
			sendData: JSON.encode(rule.json),
			mimeType: 'application/json');

		if (request.status != 200)
			throw 'Failed to add version ' + version.toString() + ' rule ' 
				+ rule.name + '. ' + request.statusText;

		Map json = JSON.decode(request.responseText);
		return new PostResponseModel(json);
	}

	static Future<PostResponseModel> deleteRule(int version, String ruleName) async
	{
		var request = await HttpRequest.request(
			'/rule/' + version.toString() + '/' + ruleName, 
			method: 'DELETE');

		if (request.status != 200)
			throw 'Failed to delete version ' + version.toString() + ' rule ' 
				+ ruleName + '. ' + request.statusText;

		Map json = JSON.decode(request.responseText);
		return new PostResponseModel(json);
	}
//
//-- Environment ------------------------------------------------------------------------------
//
	static Future<List<EnvironmentModel>> getEnvironments() async
	{
		String response = await HttpRequest.getString('/environments');
		List<Map> environmentsJson = JSON.decode(response);

		var environments = new List<EnvironmentModel>();
		for (Map environmentJson in environmentsJson)
		{
			environments.add(new EnvironmentModel(environmentJson));
		}
		return environments;
	}

	static Future<PostResponseModel> replaceEnvironments(List<EnvironmentModel> environments) async
	{
		var requestBody = environments.map((EnvironmentModel m) => m.json).toList();
		var request = await HttpRequest.request(
			'/environments',
			method: 'PUT',
			sendData: JSON.encode(requestBody),
			mimeType: 'application/json',
			responseType: 'application/json');

		if (request.status != 200)
			throw 'Failed to replace environments. ' + request.statusText;

		Map json = JSON.decode(request.responseText);
		return new PostResponseModel(json);
	}

	static Future<String> getDefaultEnvironment()
		=> HttpRequest.getString('/environment/default');

	static Future<PostResponseModel> setDefaultEnvironment(String environmentName) async
	{
		var request = await HttpRequest.request(
			'/environment/default',
			method: 'PUT',
			sendData: '"' + environmentName + '"',
			mimeType: 'application/json');

		if (request.status != 200)
			throw 'Failed to set default environment to ' + environmentName + '. ' + request.statusText;

		Map json = JSON.decode(request.responseText);
		return new PostResponseModel(json);
	}

//
//-- Application config related server methods --------------------------------------------------
//
	static Future<String> getConfig(String machine, String application, String environment, String instance)
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

	static Future<String> traceConfig(String machine, String application, String environment, String instance)
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

	static Future<String> testConfig(int version, String machine, String application, String environment, String instance)
	{
		if (machine == null || machine.isEmpty)
			throw 'Machine name can not be empty';
		
		if (application == null || application.isEmpty)
			throw 'Application name can not be empty';

		var url = '/test/' + version.toString() + '?machine=' + machine + '&application=' + application;

		if (environment != null && !environment.isEmpty)
			url = url + '&environment=' + environment;

		if (instance != null && !instance.isEmpty)
			url = url + '&instance=' + instance;

		return HttpRequest.getString(url);
	}

//
//-- Logon related server methods ------------------------------------------------------------------------------
//
	static Future<ClientCredentialsModel> getLoggedOnUser() async
	{
		String response = await HttpRequest.getString('/user');
		return new ClientCredentialsModel(JSON.decode(response));
	}

	static Future<PostResponseModel> logon(String userName, String password) async
	{
		var request = HttpRequest.request(
			'/logon', 
			method: 'POST',
			sendData: '{"username": "' + userName + '","password": "' + password + '"}',
			mimeType: 'application/json',
			responseType: 'application/json');

		if (request.status != 200)
			throw 'Failed to log on as ' + userName + '. ' + request.statusText;

		Map json = JSON.decode(request.responseText);
		return new PostResponseModel(json);
	}

	static Future<PostResponseModel> logoff() async
	{
		var request = HttpRequest.request(
			'/logoff',
			method: 'POST');

		if (request.status != 200)
			throw 'Failed to log off. ' + request.statusText;

		Map json = JSON.decode(request.responseText);
		return new PostResponseModel(json);
	}
}
