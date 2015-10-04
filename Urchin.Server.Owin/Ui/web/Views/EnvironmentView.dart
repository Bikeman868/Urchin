import 'dart:html';
import '../DataBinding/Binding.dart';
import '../DataBinding/BoundLabel.dart';
import '../DataBinding/BoundTextInput.dart';
import '../Models/EnvironmentModel.dart';
import '../ViewModels/EnvironmentViewModel.dart';
import '../Html/FormBuilder.dart';

class EnvironmentView
{
	FormBuilder _form;

	Element _heading1;
	Element _heading2;
	Element _heading3;
	Element _name;
	Element _version;
	Element _machines;
	Element _rules;

	BoundTextInput _nameBinding;
	BoundTextInput _versionBinding;

	EnvironmentView([EnvironmentViewModel viewModel])
	{
		_form = new FormBuilder();
		_heading1 = _form.addHeading('Environment Details', 1);
		_name = _form.addLabeledEdit('Environment name');
		_version = _form.addLabeledEdit('Version of rules');
		_heading2 = _form.addHeading('Machines in this environment', 2);
		_machines = _form.addList('machineList');
		_heading3 = _form.addHeading('Security for this environment', 2);
		_rules = _form.addList('securityRuleList');

		_nameBinding = new BoundTextInput(_name);
		_versionBinding = new BoundTextInput(_version);

		this.viewModel = viewModel;
	}

	EnvironmentViewModel _viewModel;
	EnvironmentViewModel get viewModel => _viewModel;
	void set viewModel(EnvironmentViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_nameBinding.binding = null;
			_versionBinding.binding = null;
		}
		else
		{
			_nameBinding.binding = value.name;
			_versionBinding.binding = value.version;
		}
	}

	void addTo(Element container)
	{
		_form.addTo(container);
	}

	void displayIn(Element container)
	{
		_form.displayIn(container);
	}
}