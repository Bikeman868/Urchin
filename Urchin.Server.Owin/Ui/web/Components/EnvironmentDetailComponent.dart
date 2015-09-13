import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../Html/FormBuilder.dart';
import '../Dto.dart';
import '../Data.dart';
import '../ApplicationEvents.dart';

class EnvironmentDetailComponent
{
	Data _data;

	Element _heading1;
	Element _heading2;
	Element _environmentName;
	Element _machines;
	Element _rules;

	EnvironmentDetailComponent(this._data);
  
	void displayIn(containerDiv)
	{
		var formBuilder = new FormBuilder();
		_heading1 = formBuilder.addHeading('Machines in this environment', 2);
		_machines = formBuilder.addList('machineList');
		_heading2 = formBuilder.addHeading('Security for this environment', 2);
		_rules = formBuilder.addList('securityRuleList');

		formBuilder.addTo(containerDiv);

		ApplicationEvents.onEnvironmentSelected.listen(_environmentSelected);
	}

	void _environmentSelected(EnvironmentSelectedEvent e) async
	{
		Map<String, EnvironmentDto> environments = await _data.getEnvironments();
		EnvironmentDto environment = environments[e.environmentName];

		_heading1.text = 'Machines in ' + environment.name + ' Environment';
		_heading2.text = 'Security for ' + environment.name + ' Environment';

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
