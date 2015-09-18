import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../Html/FormBuilder.dart';
import '../Dto.dart';
import '../Data.dart';
import '../AppEvents.dart';

class EnvironmentDetailComponent
{
	Data _data;

	FormBuilder _form;

	Element _heading1;
	Element _heading2;
	Element _heading3;
	Element _environmentName;
	Element _version;
	Element _machines;
	Element _rules;

	StreamSubscription<EnvironmentSelectedEvent> _environmentSelectedSubscription;

	EnvironmentDetailComponent(this._data)
	{
		_form = new FormBuilder();
		_heading1 = _form.addHeading('Machines in this environment', 1);
		_version = _form.addLabeledField('Version of rules');
		_heading2 = _form.addHeading('Machines in this environment', 2);
		_machines = _form.addList('machineList');
		_heading3 = _form.addHeading('Security for this environment', 2);
		_rules = _form.addList('securityRuleList');

		_environmentSelectedSubscription = AppEvents.environmentSelected.listen(_environmentSelected);
	}
  
	void dispose()
	{
		_environmentSelectedSubscription.cancel();
		_environmentSelectedSubscription = null;
	}

	void displayIn(containerDiv)
	{
		_form.addTo(containerDiv);
	}

	void _environmentSelected(EnvironmentSelectedEvent e) async
	{
		Map<String, EnvironmentDto> environments = await _data.getEnvironments();
		EnvironmentDto environment = environments[e.environmentName];

		_heading1.text = environment.name + ' Environment';
		_heading2.text = 'Machines in ' + environment.name + ' Environment';
		_heading3.text = 'Security for ' + environment.name + ' Environment';

		_version.text = environment.version.toString();

		_machines.children.clear();
		if (environment.machines != null)
		{
			for (String machineName in environment.machines)
			{
				var element = new LIElement();
				element.text = machineName;
				element.classes.add('machineName');
				_machines.children.add(element);
			}
		}

		_rules.children.clear();
		if (environment.securityRules != null)
		{
			for (SecurityRuleDto rule in environment.securityRules)
			{
				var element = new LIElement();
				element.text = 'Allowed IP ' + rule.startIp + ' => ' + rule.endIp;
				element.classes.add('securityRule');
				_rules.children.add(element);
			}
		}
}
}
