import 'dart:async';
import 'dart:html';
import '../../MVVM/Mvvm.dart';
import '../../ViewModels/DatacenterRuleViewModel.dart';

class DatacenterRuleNameView extends View
{
	SpanElement _ruleName;

	DatacenterRuleNameView([DatacenterRuleViewModel viewModel])
	{
		_ruleName = addSpan(className: 'datacenter-rule');
		this.viewModel = viewModel;
	}

	DatacenterRuleViewModel _viewModel;
	DatacenterRuleViewModel get viewModel => _viewModel;

	StreamSubscription<String> _applicationChange;
	StreamSubscription<String> _instanceChange;
	StreamSubscription<String> _environmentChange;
	StreamSubscription<String> _machineChange;

	void set viewModel(DatacenterRuleViewModel value)
	{
		if (_applicationChange != null)
		{
			_applicationChange.cancel();
			_applicationChange = null;
		}

		if (_instanceChange != null)
		{
			_instanceChange.cancel();
			_instanceChange = null;
		}

		if (_environmentChange != null)
		{
			_environmentChange.cancel();
			_environmentChange = null;
		}

		if (_machineChange != null)
		{
			_machineChange.cancel();
			_machineChange = null;
		}

		_viewModel = value;

		if (value != null)
		{
			_applicationChange = value.application.onChange.listen(_changed);
			_instanceChange = value.instance.onChange.listen(_changed);
			_environmentChange = value.environment.onChange.listen(_changed);
			_machineChange = value.machine.onChange.listen(_changed);
		}

		_changed(null);
	}

	void _changed(String value)
	{
		if (_viewModel == null)
		{
			_ruleName.text = '';
		}
		else
		{
			var application = _viewModel.application.getProperty();
			var instance = _viewModel.instance.getProperty();
			var machine = _viewModel.machine.getProperty();
			var environment = _viewModel.environment.getProperty();

			var hasApplication = application != null && application.length > 0;
			var hasInstance = instance != null && instance.length > 0;
			var hasMachine = machine != null && machine.length > 0;
			var hasEnvironment = environment != null && environment.length > 0;

			var name = '';

			if (hasInstance)
			{
				name = 'The ' + instance + ' instance';
				if (hasApplication)
					name += ' of the ' + application + 'application ';
				else
					name += ' of all applications ';
			}
			else if (hasApplication)
			{
				name = 'All instances of the ' + application + ' application ';
			}
			else
			{
				name = 'All software ';
			}

			if (hasMachine)
			{
				name += " running on the " + machine + ' server';
				if (hasEnvironment)
					name += " in the " + environment + ' environment';
			}
			else if (hasEnvironment)
			{
				name += " running in the " + environment + ' environment';
			}

			_ruleName.text = name;
		}
	}
}