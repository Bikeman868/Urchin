import 'dart:html';
import 'dart:convert';
import 'dart:async';

class Dto
{
	Map json;
	Dto(this.json);
}

class RuleDto extends Dto
{
	List<VariableDto> variables;

	RuleDto(Map json): super(json)
	{
		variables = new List<VariableDto>();
    
		List jsonVariables = json['variables'];
		if (jsonVariables != null)
		{
			for (var v in jsonVariables)
			{
				variables.add(new VariableDto(v));
			}
		}
	}
  
	String get name => json['name'];
	set name(String value) => json['name'] = value;
  
	String get machine => json['machine'];
	set machine(String value) => json['machine'] = value;
  
	String get application => json['application'];
	set application(String value) => json['application'] = value;
  
	String get environment => json['environment'];
	set environment(String value) => json['environment'] = value;
  
	String get instance => json['instance'];
	set instance(String value) => json['instance'] = value;

	String get config => json['config'];
	set config(String value) => json['config'] = value;
}

class VariableDto extends Dto
{
	VariableDto(Map json): super(json){}

	String get name => json['name'];
	set name(String value) => json['name'] = value;
  
	String get value => json['value'];
	set value(String value) => json['value'] = value;
}

class EnvironmentDto extends Dto
{
	EnvironmentDto(Map json): super(json){}

	String get name => json['name'];
	set name(String value) => json['name'] = value;
  
	List<String> get machines => json['machines'];
	set machines(List<String> value) => json['machines'] = value;
}