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

	FormBuilder _form;

	SpanElement _heading;
	SpanElement _ruleName;
	SpanElement _machine;
	SpanElement _environment;
	SpanElement _instance;
	SpanElement _application;
	Element _config;
	Element _variables;

	StreamSubscription<RuleSelectedEvent> _onRuleSelectedSubscription;

	RuleDetailComponent(this._data)
	{
		_form = new FormBuilder();

		_heading = _form.addHeading('Rule Details', 1);
		_ruleName = _form.addLabeledField('Rule name:');
		_machine = _form.addLabeledField('Machine name:');
		_environment = _form.addLabeledField('Environment name:');
		_instance = _form.addLabeledField('Instance name:');
		_application = _form.addLabeledField('Application name:');

		_form.addHeading('Configuration', 2);
		_config = _form.addContainer();

		_form.addHeading('Variables', 2);
		_variables = _form.addContainer();

		_onRuleSelectedSubscription = ApplicationEvents.onRuleSelected.listen(_ruleSelected);
	}
  
	void dispose()
	{
		_onRuleSelectedSubscription.cancel();
		_onRuleSelectedSubscription = null;
	}
  
	void displayIn(containerDiv)
	{
		_form.addTo(containerDiv);
	}

	void _ruleSelected(RuleSelectedEvent e) async
	{
		var ruleName = e.ruleName;

		VersionData versionData = _data.getVersion(1);
		RuleVersionDto ruleVersion = await versionData.getRules();
		RuleDto rule = ruleVersion.rules[ruleName];

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
