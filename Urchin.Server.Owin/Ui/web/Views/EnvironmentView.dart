import 'dart:html';
import '../DataBinding/BoundLabel.dart';
import '../DataBinding/BoundTextInput.dart';
import '../Models/EnvironmentModel.dart';
import '../ViewModels/EnvironmentViewModel.dart';
import '../Html/FormBuilder.dart';
import '../Views/MachineListView.dart';

class EnvironmentView
{
	FormBuilder _form;

	Element heading1;
	Element heading2;
	Element heading3;
	Element name;
	Element version;
	Element machines;
	Element rules;

	BoundTextInput _nameBinding;
	BoundTextInput _versionBinding;

	MachineListView _machineListView;

	EnvironmentView([EnvironmentViewModel viewModel])
	{
		_form = new FormBuilder();
		heading1 = _form.addHeading('Environment Details', 1);
		name = _form.addLabeledEdit('Environment name');
		version = _form.addLabeledEdit('Version of rules');
		heading2 = _form.addHeading('Machines in this environment', 2);
		machines = _form.addContainer();
		heading3 = _form.addHeading('Security for this environment', 2);
		rules = _form.addContainer();

		_nameBinding = new BoundTextInput(name);
		_versionBinding = new BoundTextInput(version);

		_machineListView = new MachineListView();
		_machineListView.addTo(machines);

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
			_machineListView.viewModel = null;
			rules.children.clear();
		}
		else
		{
			_nameBinding.binding = value.name;
			_versionBinding.binding = value.version;
			_machineListView.viewModel = value.machines;
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