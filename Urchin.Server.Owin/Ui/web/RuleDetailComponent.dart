import 'dart:html';
import 'dart:convert';
import 'dart:async';

import 'Dto.dart';
import 'Data.dart';
import 'ApplicationEvents.dart';

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
		_heading = new SpanElement();
		_heading.classes.add('panelTitle');
		_heading.text = 'Rule Details';
		containerDiv.children.add(_heading);

		_ruleName = new SpanElement();
		_ruleName.classes.add('ruleField');
		containerDiv.children.add(_ruleName);

		_machine = new SpanElement();
		_machine.classes.add('ruleField');
		containerDiv.children.add(_machine);

		_environment = new SpanElement();
		_environment.classes.add('ruleField');
		containerDiv.children.add(_environment);

		_instance = new SpanElement();
		_instance.classes.add('ruleField');
		containerDiv.children.add(_instance);

		_application = new SpanElement();
		_application.classes.add('ruleField');
		containerDiv.children.add(_application);

		_config = new SpanElement();
		_config.classes.add('ruleField');
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
