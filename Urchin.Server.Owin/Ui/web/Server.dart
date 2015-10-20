import 'dart:html';
import 'dart:async';
import 'dart:convert';

import 'Models/ClientCredentialsModel.dart';
import 'Models/EnvironmentModel.dart';
import 'Models/PostResponseModel.dart';
import 'Models/RuleModel.dart';
import 'Models/VersionModel.dart';
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

	static Future<HttpRequest> deleteOldVersions()
		=> HttpRequest.request(
			'/versions', 
			method: 'DELETE');

	static Future<HttpRequest> updateVersion(int version, VersionModel versionDto)  async
		=> HttpRequest.request(
			'/version/' + version.toString(), 
			method: 'PUT',
			sendData: JSON.encode(versionDto),
			mimeType: 'application/json');
  
	static Future<HttpRequest> deleteVersion(int version)
		=> HttpRequest.request(
			'/version/' + version.toString(), 
			method: 'DELETE');
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

	static Future<HttpRequest> addRules(int version, List<RuleModel> rules) 
		=> HttpRequest.request(
			'/rules/' + version.toString(), 
			method: 'POST',
			sendData: JSON.encode(rules),
			mimeType: 'application/json');

	static Future<HttpRequest> updateRules(int version, List<RuleModel> rules) 
		=> HttpRequest.request(
			'/rules/' + version.toString(), 
			method: 'PUT',
			sendData: JSON.encode(rules),
			mimeType: 'application/json');

	static Future<String> getRule(int version, String ruleName) 
		=> HttpRequest.getString(
			'/rule/' + version.toString() + '/' + ruleName);

	static Future<HttpRequest> updateRenameRule(int version, String oldName, RuleModel rule) 
		=> HttpRequest.request(
			'/rule/' + version.toString() + '/' + oldName, 
			method: 'PUT',
			sendData: JSON.encode(rule),
			mimeType: 'application/json');

	static Future<HttpRequest> addRule(int version, RuleModel rule) 
		=> HttpRequest.request(
			'/rule/' + version.toString(), 
			method: 'POST',
			sendData: JSON.encode(rule),
			mimeType: 'application/json');

	static Future<HttpRequest> deleteRule(int version, String ruleName) 
		=> HttpRequest.request(
			'/rule/' + version.toString() + '/' + ruleName, 
			method: 'DELETE');
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

	static Future<String> replaceEnvironments(List<EnvironmentModel> environments) async
	{
		var requestBody = environments.map((EnvironmentModel m) => m.json).toList();
		var httpResponse = await HttpRequest.request(
			'/environments',
			method: 'PUT',
			sendData: JSON.encode(requestBody),
			mimeType: 'application/json',
			responseType: 'application/json');
		Map responseJson = JSON.decode(httpResponse.responseText);
		if (responseJson['success']) return null;
		return responseJson['error'];
	}

	static Future<String> getDefaultEnvironment()
		=> HttpRequest.getString('/environment/default');

	static Future<HttpRequest> setDefaultEnvironment(String environmentName)
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
