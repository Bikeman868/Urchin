import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../Html/FormBuilder.dart';
import '../Html/JsonHighlighter.dart';
import '../Dto.dart';
import '../Data.dart';
import '../ApplicationEvents.dart';

class RuleDetailComponent
{
	Data _data;

	SpanElement _heading;
	SpanElement _ruleName;
	SpanElement _machine;
	SpanElement _environment;
	SpanElement _instance;
	SpanElement _application;
	Element _config;
	Element _variables;

	RuleDetailComponent(this._data);
  
	void displayIn(containerDiv)
	{
		var formBuilder = new FormBuilder();

		_heading = formBuilder.addHeading('Rule Details', 1);
		_ruleName = formBuilder.addLabeledField('Rule name:');
		_machine = formBuilder.addLabeledField('Machine name:');
		_environment = formBuilder.addLabeledField('Environment name:');
		_instance = formBuilder.addLabeledField('Instance name:');
		_application = formBuilder.addLabeledField('Application name:');

		formBuilder.addHeading('Configuration', 2);
		_config = formBuilder.addContainer();

		formBuilder.addHeading('Variables', 2);
		_variables = formBuilder.addContainer();

		formBuilder.addTo(containerDiv);

		ApplicationEvents.onRuleSelected.listen(_ruleSelected);
	}

	void _ruleSelected(RuleSelectedEvent e)
	{
		var ruleName = e.ruleName;

		RuleDto rule = _data.rules[ruleName];

		_heading.text = rule.name + ' Rule';
		_ruleName.text = rule.name;
		_machine.text = rule.machine;
		_environment.text = rule.environment;
		_instance.text = rule.instance;
		_application.text = rule.application;

		JsonHighlighter.displayIn(_config, rule.config);

		_variables.children.clear();
		if (rule.variables != null && rule.variables.length > 0)
		{
			var formBuilder = new FormBuilder();
			for (var variable in rule.variables)
			{
				formBuilder.addHeading(variable.name, 3);
				var value = formBuilder.addContainer();
				JsonHighlighter.displayIn(value, variable.value);
			}
			formBuilder.addTo(_variables);
		}
	}
}
