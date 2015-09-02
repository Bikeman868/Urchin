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
	SpanElement _config;

	RuleDetailComponent(this._data);
  
	void displayIn(containerDiv)
	{
		var formBuilder = new FormBuilder(containerDiv);

		_heading = formBuilder.addHeading('Rule Details');
		_ruleName = formBuilder.addLabeledField('Rule name:');
		_machine = formBuilder.addLabeledField('Machine name:');
		_environment = formBuilder.addLabeledField('Environment name:');
		_instance = formBuilder.addLabeledField('Instance name:');
		_application = formBuilder.addLabeledField('Application name:');

		_config = new SpanElement();
		_config.classes.add('dataField');
		containerDiv.children.add(_config);

		ApplicationEvents.onRuleSelected.listen(_ruleSelected);
	}

	void _ruleSelected(RuleSelectedEvent e)
	{
		var ruleName = e.ruleName;

		_heading.text = ruleName + ' Rule';

		RuleDto rule = _data.rules[ruleName];

		_ruleName.text = rule.name;
		_machine.text = rule.machine;
		_environment.text = rule.environment;
		_instance.text = rule.instance;
		_application.text = rule.application;
		_config.text = rule.config;
	}
}
