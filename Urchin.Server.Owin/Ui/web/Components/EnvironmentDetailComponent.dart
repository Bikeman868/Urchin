import 'dart:html';
import 'dart:convert';
import 'dart:async';

import 'FormBuilder.dart';
import '../Dto.dart';
import '../Data.dart';
import '../ApplicationEvents.dart';

class EnvironmentDetailComponent
{
	Data _data;

	SpanElement _heading1;
	SpanElement _heading2;
	SpanElement _environmentName;
	UListElement _machines;

	EnvironmentDetailComponent(this._data);
  
	void displayIn(containerDiv)
	{
		var formBuilder = new FormBuilder(containerDiv);
		//_heading1 = formBuilder.addHeading('Environment Details', 1);
		//_environmentName = formBuilder.addLabeledField('Environment name:');
		_heading2 = formBuilder.addHeading('Machines in this environment', 1);

		_machines = new UListElement();
		_machines.classes.add('machineList');
		containerDiv.children.add(_machines);

		ApplicationEvents.onEnvironmentSelected.listen(_environmentSelected);
	}

	void _environmentSelected(EnvironmentSelectedEvent e)
	{
		EnvironmentDto environment = _data.environments[e.environmentName];

		//_heading1.text = environment.name + ' Environment';
		_heading2.text = 'Machines in ' + environment.name;
		//_environmentName.text = environment.name;

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
	}
}
