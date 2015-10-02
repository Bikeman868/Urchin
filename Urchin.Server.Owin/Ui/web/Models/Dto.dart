import 'dart:html';
import 'dart:convert';
import 'dart:async';

class Dto
{
	Map json;
	bool isModified;
	bool _loading;

	void startLoading(Map json)
	{
		_loading = true;
		this.json = json;
		isModified = false;
	}

	void finishedLoading()
	{
		_loading = false;
	}

	void _propertyModified()
	{
		if (!_loading)
			isModified = true;
	}

	void setProperty(String name, dynamic value)
	{
		json[name] = value;
		_propertyModified();
	}
}

class RuleDto extends Dto
{
	List<VariableDto> variables;

	RuleDto(Map json)
	{
		Reload(json);
	}

	void Reload(Map json)
	{
		startLoading(json);

		variables = new List<VariableDto>();
    
		List jsonVariables = json['variables'];
		if (jsonVariables != null)
		{
			for (var v in jsonVariables)
			{
				variables.add(new VariableDto(v));
			}
		}

		finishedLoading();
	}
  
	String get name => json['name'];
	set name(String value) { setProperty('name', value); }
  
	String get machine => json['machine'];
	set machine(String value) { setProperty('machine', value); }
  
	String get application => json['application'];
	set application(String value) { setProperty('application', value); }
  
	String get environment => json['environment'];
	set environment(String value) { setProperty('environment', value); }
  
	String get instance => json['instance'];
	set instance(String value) { setProperty('instance', value); }

	String get config => json['config'];
	set config(String value) { setProperty('config', value); }
}

class VersionDto extends Dto
{
	VersionDto(Map json)
	{
		Reload(json);
	}

	void Reload(Map json)
	{
		startLoading(json);
		finishedLoading();
	}

	String get name => json['name'];
	set name(String value) { setProperty('name', value); }
  
	int get version => json['version'];
	set version(int value) { setProperty('version', value); }
}

class RuleVersionDto extends VersionDto
{
	Map<String, RuleDto> rules;

	RuleVersionDto(Map json): super(json)
	{
		Reload(json);
	}

	void Reload(Map json)
	{
		startLoading(json);

		rules = new Map<String, RuleDto>();
    
		List jsonRules = json['rules'];
		if (jsonRules != null)
		{
			for (var r in jsonRules)
			{
				rules[r['name']] = new RuleDto(r);
			}
		}

		finishedLoading();
	}
}

class VariableDto extends Dto
{
	VariableDto(Map json)
	{
		Reload(json);
	}

	void Reload(Map json)
	{
		startLoading(json);
		finishedLoading();
	}

	String get name => json['name'];
	set name(String value) { setProperty('name', value); }
  
	String get value => json['value'];
	set value(String value) { setProperty('value', value); }
}

class SecurityRuleDto extends Dto
{
	SecurityRuleDto(Map json)
	{
		Reload(json);
	}

	void Reload(Map json)
	{
		startLoading(json);
		finishedLoading();
	}

	String get startIp => json['startIp'];
	set startIp(String value) { setProperty('startIp', value); }
  
	String get endIp => json['endIp'];
	set endIp(String value) { setProperty('endIp', value); }
}

class PostResponseDto extends Dto
{
	PostResponseDto(Map json)
	{
		Reload(json);
	}

	void Reload(Map json)
	{
		startLoading(json);
		finishedLoading();
	}

	bool get success => json['success'];
	bool get error => json['error'];
	bool get id => json['id'];
}

class ClientCredentials extends Dto
{
	ClientCredentials(Map json)
	{
		Reload(json);
	}

	void Reload(Map json)
	{
		startLoading(json);
		finishedLoading();
	}

	String get ipAddress => json['ip'];
	bool get isAdmin => json['admin'];
	bool get isLoggedOn => json['loggedOn'];
	String get userName => json['userName'];
}