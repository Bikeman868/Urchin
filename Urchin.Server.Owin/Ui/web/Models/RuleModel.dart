import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../Models/ModelBase.dart';
import '../Models/VariableModel.dart';

class RuleModel extends ModelBase
{
	List<VariableModel> variables;

	RuleModel(Map json)
	{
		Reload(json);
	}

	void Reload(Map json)
	{
		startLoading(json);

		variables = new List<VariableModel>();
    
		List jsonVariables = json['variables'];
		if (jsonVariables != null)
		{
			for (var v in jsonVariables)
			{
				variables.add(new VariableModel(v));
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

