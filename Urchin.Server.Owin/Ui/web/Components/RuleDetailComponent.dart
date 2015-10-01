import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../Html/FormBuilder.dart';
import '../Html/HtmlBuilder.dart';
import '../Html/JsonHighlighter.dart';
import '../Models/Dto.dart';
import '../Models/Data.dart';
import '../Models/VersionData.dart';
import '../Events/AppEvents.dart';

class RuleDetailComponent
{
	Data _data;

	HtmlBuilder _html;

	Element _ruleDetail;
	SpanElement _heading;
	SpanElement _ruleName;
	SpanElement _machine;
	SpanElement _environment;
	SpanElement _instance;
	SpanElement _application;
	Element _config;
	Element _variables;

	StreamSubscription<RuleSelectedEvent> _ruleSelectedSubscription;

	RuleDetailComponent(this._data)
	{
		_html = new HtmlBuilder();
		_heading = _html.addHeading(2, 'Rule Details');
		_ruleDetail = _html.addContainer();
		_ruleDetail.hidden = true;

		var form = new FormBuilder();

		_ruleName = form.addLabeledField('Rule name:');
		_machine = form.addLabeledField('Machine name:');
		_environment = form.addLabeledField('Environment name:');
		_instance = form.addLabeledField('Instance name:');
		_application = form.addLabeledField('Application name:');

		form.addHeading('Configuration', 2);
		_config = form.addContainer();

		form.addHeading('Variables', 2);
		_variables = form.addContainer();
		form.addTo(_ruleDetail);

		_ruleSelectedSubscription = AppEvents.ruleSelected.listen(_ruleSelected);
	}
  
	void dispose()
	{
		_ruleSelectedSubscription.cancel();
		_ruleSelectedSubscription = null;
	}
  
	void displayIn(containerDiv)
	{
		_html.addTo(containerDiv);
	}

	void _ruleSelected(RuleSelectedEvent e) async
	{
		if (e.version == null || e.ruleName == null)
		{
			_heading.text = 'No rule selected';
			_ruleDetail.hidden = true;
			return;
		}

		_heading.text = 'Version ' + e.version.toString() + ' of the ' + e.ruleName + ' rule';
		_ruleDetail.hidden = false;

		try
		{
			VersionData versionData = await _data.getVersion(e.version);
			RuleVersionDto ruleVersion = await versionData.getRules();
			RuleDto rule = ruleVersion.rules[e.ruleName];

			_ruleName.text = rule.name;
			_machine.text = rule.machine;
			_environment.text = rule.environment;
			_instance.text = rule.instance;
			_application.text = rule.application;

			JsonHighlighter.displayIn(_config, rule.config);

			_variables.children.clear();
			if (rule.variables != null && rule.variables.length > 0)
			{
				var htmlBuilder = new HtmlBuilder();
				var table = htmlBuilder.addTable();
				for (var variable in rule.variables)
				{
					var row = htmlBuilder.addTableRow(table);
					htmlBuilder.addTableCell(row, cell: variable.name, className: 'variableName');
					var value = htmlBuilder.addTableCell(row);
					JsonHighlighter.displayIn(value, variable.value);
				}
				htmlBuilder.addTo(_variables);
			}
		}
		catch(e)
		{
			_ruleDetail.hidden = true;
		}
	}
}
