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

	Element _heading;
	Element _environmentName;
	UListElement _machines;

	EnvironmentDetailComponent(this._data);
  
	void displayIn(containerDiv)
	{
		var formBuilder = new FormBuilder();
		_heading = formBuilder.addHeading('Machines in this environment', 2);
		_machines = formBuilder.addList('machineList');

		formBuilder.addTo(containerDiv);

		ApplicationEvents.onEnvironmentSelected.listen(_environmentSelected);
	}

	void _environmentSelected(EnvironmentSelectedEvent e)
	{
		EnvironmentDto environment = _data.environments[e.environmentName];

		_heading.text = 'Machines in ' + environment.name + ' Environment';

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
