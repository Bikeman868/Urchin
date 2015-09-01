import 'dart:html';
import 'dart:convert';

final Data data = new Data();

void main()
{
  var menu = querySelector('#menuDiv');

  var button = new ButtonElement();
  button.text = "Get Rules";
  button.onClick.listen(fetchRules);
  menu.children.add(button);
}

void fetchRules(MouseEvent e)
{
  var div = querySelector('#centreDiv');
  displayRules(div, data.rules);
}

void displayRules(div, Map<String, RuleDto> rules)
{
  var list = new UListElement();
  for (RuleDto rule in rules.values){
    var element = new LIElement();
	element.text = rule.name;
	list.children.add(element);
  }
  div.children.clear();
  div.children.add(list);
}

class Data{
	List<String> ruleNames;
	Map<String, RuleDto> rules;

	Data()
	{
		loadAll();
	}

	loadAll() async
	{
		await loadRuleNames();
		await loadRules();
	}

	loadRuleNames() async
	{
		String content = Server.getRules();
		var rules = JSON.decode(content);

		List<String> ruleNames = new List<String>();
		for (var rule in rules)
		{
			ruleNames.add(rule['name']);
		}
		this.ruleNames = ruleNames;
	}

	loadRules() async 
	{
		var result = new Map<String, RuleDto>();
		for (var ruleName in ruleNames)
		{
			String content = await Server.getRule(ruleName);
			var rule = JSON.decode(content);
			result[ruleName] = new RuleDto(rule);
		}
		this.rules = rules;
	}
}

class Server
{
  static getRule(String ruleName) => HttpRequest.getString('/rule/' + ruleName);
  static getRules() => HttpRequest.getString('/rules');
}

/*
class Server
{
  static getRule(String ruleName) => '{"name", "Rule 1"}';
  static getRules() => '[{"name":"Rule 1"},{"name":"Rule 2"}]';
}
*/

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
		for (var v in json['variables'])
		{
			variables.add(new VariableDto(v));
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