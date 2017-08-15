import 'dart:html';
import '../../MVVM/Mvvm.dart';
import '../../ViewModels/DatacenterRuleViewModel.dart';
import '../../Events/AppEvents.dart';

class DatacenterRuleDisplayView extends View
{
	BoundLabel<String> _datacenter;
	BoundLabel<String> _machine;
	BoundLabel<String> _environment;
	BoundLabel<String> _instance;
	BoundLabel<String> _application;

	DatacenterRuleDisplayView([DatacenterRuleViewModel viewModel])
	{
		_datacenter = new BoundLabel<String>(addSpan(), 
			formatMethod: (s)
			{
				if (s == null || s.length == 0)
					return 'No datacenter';
				return 'Apply ' + s + ' datacenter rules to';
			});

		_instance = new BoundLabel<String>(addSpan(), 
			formatMethod: (s)
			{
				if (s == null || s.length == 0)
					return ' all instances';
				return ' the ' + s + ' instance';
			});

		_application = new BoundLabel<String>(addSpan(), 
			formatMethod: (s)
			{
				if (s == null || s.length == 0)
					return ' of all applications';
				return ' of the ' + s + ' application';
			});

		_machine = new BoundLabel<String>(addSpan(), 
			formatMethod: (s)
			{
				if (s == null || s.length == 0)
					return ' running on any computer';
				return ' running on ' + s;
			});

		_environment = new BoundLabel<String>(addSpan(), 
			formatMethod: (s)
			{
				if (s == null || s.length == 0)
					return ' in any environment';
				return ' in the ' + s + ' environment';
			});

		var buttonBar = addContainer(className: 'button-bar');
		addButton("Edit", _editClicked, parent: buttonBar);

		this.viewModel = viewModel;
	}

	DatacenterRuleViewModel _viewModel;
	DatacenterRuleViewModel get viewModel => _viewModel;

	void set viewModel(DatacenterRuleViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_machine.binding = null;
			_environment.binding = null;
			_datacenter.binding = null;
			_instance.binding = null;
			_application.binding = null;
		}
		else
		{
			_machine.binding = value.machine;
			_environment.binding = value.environment;
			_datacenter.binding = value.datacenter;
			_instance.binding = value.instance;
			_application.binding = value.application;
		}
	}

	void _editClicked(MouseEvent e)
	{
		if (viewModel != null)
			AppEvents.datacenterRuleEdit.raise(new DatacenterRuleEditEvent(viewModel));
	}
}