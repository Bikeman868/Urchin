import 'dart:html';
import 'dart:convert';
import 'dart:async';

import 'FormBuilder.dart';
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
		var formBuilder = new FormBuilder(containerDiv);

		_heading = formBuilder.addHeading('Rule Details', 1);
		_ruleName = formBuilder.addLabeledField('Rule name:');
		_machine = formBuilder.addLabeledField('Machine name:');
		_environment = formBuilder.addLabeledField('Environment name:');
		_instance = formBuilder.addLabeledField('Instance name:');
		_application = formBuilder.addLabeledField('Application name:');

		formBuilder.addHeading('Configuration', 1);
		_config = formBuilder.addContainer();

		formBuilder.addHeading('Variables', 1);
		_variables = formBuilder.addContainer();

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

		FormBuilder.replaceJSON(_config, rule.config);

		_variables.children.clear();
		if (rule.variables != null && rule.variables.length > 0)
		{
			var formBuilder = new FormBuilder(_variables);
			for (var variable in rule.variables)
			{
				formBuilder.addHeading(variable.name, 2);
				var value = formBuilder.addContainer();
				FormBuilder.replaceJSON(value, variable.value);
			}
		}
	}
}
