import 'dart:html';
import 'dart:convert';
import 'dart:async';

class Dto
{
	Map json;
	bool isModified;
	bool _loading;

	void _startLoading(Map json)
	{
		_loading = true;
		this.json = json;
		isModified = false;
	}

	void _finishedLoading()
	{
		_loading = false;
	}

	void _propertyModified()
	{
		if (!_loading)
			isModified = true;
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
		_startLoading(json);

		variables = new List<VariableDto>();
    
		List jsonVariables = json['variables'];
		if (jsonVariables != null)
		{
			for (var v in jsonVariables)
			{
				variables.add(new VariableDto(v));
			}
		}

		_finishedLoading();
	}
  
	String get name => json['name'];
	set name(String value) 
	{
		json['name'] = value;
		_propertyModified();
	}
  
	String get machine => json['machine'];
	set machine(String value)
	{
		json['machine'] = value;
		_propertyModified();
	}
  
	String get application => json['application'];
	set application(String value)
	{
		json['application'] = value;
		_propertyModified();
	}
  
	String get environment => json['environment'];
	set environment(String value)
	{
		json['environment'] = value;
		_propertyModified();
	}
  
	String get instance => json['instance'];
	set instance(String value)
	{
		json['instance'] = value;
		_propertyModified();
	}

	String get config => json['config'];
	set config(String value)
	{
		json['config'] = value;
		_propertyModified();
	}
}

class VersionDto extends Dto
{
	VersionDto(Map json)
	{
		Reload(json);
	}

	void Reload(Map json)
	{
		_startLoading(json);
		_finishedLoading();
	}

	String get name => json['name'];
	set name(String value)
	{
		json['name'] = value;
		_propertyModified();
	}
  
	int get version => json['version'];
	set version(int value)
	{
		json['version'] = value;
		_propertyModified();
	}
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
		_startLoading(json);

		rules = new Map<String, RuleDto>();
    
		List jsonRules = json['rules'];
		if (jsonRules != null)
		{
			for (var r in jsonRules)
			{
				rules[r['name']] = new RuleDto(r);
			}
		}

		_finishedLoading();
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
		_startLoading(json);
		_finishedLoading();
	}

	String get name => json['name'];
	set name(String value)
	{
		json['name'] = value;
		_propertyModified();
	}
  
	String get value => json['value'];
	set value(String value)
	{
		json['value'] = value;
		_propertyModified();
	}
}

class EnvironmentDto extends Dto
{
	List<SecurityRuleDto> securityRules;

	EnvironmentDto(Map json)
	{
		Reload(json);
	}

	void Reload(Map json)
	{
		_startLoading(json);

		securityRules = new List<SecurityRuleDto>();
    
		List jsonRules = json['securityRules'];
		if (jsonRules != null)
		{
			for (Map r in jsonRules)
			{
				securityRules.add(new SecurityRuleDto(r));
			}
		}

		_finishedLoading();
	}

	String get name => json['name'];
	set name(String value)
	{
		json['name'] = value;
		_propertyModified();
	}
  
	int get version => json['version'];
	set version(int value)
	{
		json['version'] = value;
		_propertyModified();
	}
  
	List<String> get machines => json['machines'];
	set machines(List<String> value)
	{
		json['machines'] = value;
		_propertyModified();
	}
}

class SecurityRuleDto extends Dto
{
	SecurityRuleDto(Map json)
	{
		Reload(json);
	}

	void Reload(Map json)
	{
		_startLoading(json);
		_finishedLoading();
	}

	String get startIp => json['startIp'];
	set startIp(String value)
	{
		json['startIp'] = value;
		_propertyModified();
	}
  
	String get endIp => json['endIp'];
	set endIp(String value)
	{
		json['endIp'] = value;
		_propertyModified();
	}
}

class PostResponseDto extends Dto
{
	PostResponseDto(Map json)
	{
		Reload(json);
	}

	void Reload(Map json)
	{
		_startLoading(json);
		_finishedLoading();
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
		_startLoading(json);
		_finishedLoading();
	}

	String get ipAddress => json['ip'];
	bool get isAdmin => json['admin'];
	bool get isLoggedOn => json['loggedOn'];
	String get userName => json['userName'];
}