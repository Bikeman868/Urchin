import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../Html/FormBuilder.dart';
import '../Models/Dto.dart';
import '../Models/Data.dart';
import '../Models/EnvironmentDto.dart';
import '../Events/AppEvents.dart';
import '../DataBinding/BoundLabel.dart';
import '../ViewModels/EnvironmentViewModel.dart';
import '../Views/EnvironmentView.dart';

class EnvironmentDetailComponent
{
	Data _data;
	EnvironmentView _view;
	StreamSubscription<EnvironmentSelectedEvent> _environmentSelectedSubscription;

	EnvironmentDetailComponent(this._data)
	{
		_view = new EnvironmentView();
		_environmentSelectedSubscription = AppEvents.environmentSelected.listen(_environmentSelected);
	}
  
	void dispose()
	{
		_environmentSelectedSubscription.cancel();
		_environmentSelectedSubscription = null;
	}

	void displayIn(containerDiv)
	{
		_view.displayIn(containerDiv);
	}

	void _environmentSelected(EnvironmentSelectedEvent e) async
	{
		Map<String, EnvironmentDto> environments = await _data.getEnvironments();
		EnvironmentDto environment = environments[e.environmentName];
		EnvironmentViewModel viewModel = new EnvironmentViewModel(environment);
		_view.viewModel = viewModel;

		/*
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
		*/
	}
}
