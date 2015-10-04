import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../Html/FormBuilder.dart';
import '../DataLayer/Data.dart';
import '../Models/EnvironmentModel.dart';
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
		_view.viewModel = e.environment;

		/*
		_rules.children.clear();
		if (environment.securityRules != null)
		{
			for (SecurityRuleModel rule in environment.securityRules)
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
