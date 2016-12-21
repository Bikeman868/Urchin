import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundLabel.dart';
import '../../MVVM/BoundTextInput.dart';
import '../../MVVM/BoundList.dart';

import '../../Models/MachineModel.dart';
import '../../Models/SecurityRuleModel.dart';

import '../../ViewModels/EnvironmentViewModel.dart';
import '../../ViewModels/MachineViewModel.dart';
import '../../ViewModels/SecurityRuleViewModel.dart';

import '../../Views/Machine/MachineListElementView.dart';
import '../../Views/SecurityRule/SecurityRuleListElementView.dart';

class EnvironmentView extends View
{
	Element heading1;
	Element heading2;
	Element heading3;
	Element name;
	Element version;
	Element machines;
	Element rules;

	BoundTextInput _nameBinding;
	BoundTextInput _versionBinding;
	BoundList<MachineModel, MachineViewModel, MachineListElementView> _machinesBinding;
	BoundList<SecurityRuleModel, SecurityRuleViewModel, SecurityRuleListElementView> _rulesBinding;
	BoundLabel _titleBinding1;
	BoundLabel _titleBinding2;

	EnvironmentView([EnvironmentViewModel viewModel])
	{
		heading1 = addHeading(1, 'Environment Details');

		var form = addForm();
		name = addLabeledEdit(form, 'Environment name');
		version = addLabeledEdit(form, 'Version of rules');

		heading2 = addHeading(2, 'Environment Computers');
		machines = addContainer();

		heading3 = addHeading(2, 'Allowed IP Address Ranges');
		rules = addContainer();

		_nameBinding = new BoundTextInput(name);
		_versionBinding = new BoundTextInput(version);
		_titleBinding1 = new BoundLabel(heading1, formatMethod: (s) => s + ' Environment');
		_titleBinding2 = new BoundLabel(heading2, formatMethod: (s) => s + ' Computers');

		_machinesBinding = new BoundList<MachineModel, MachineViewModel, MachineListElementView>(
			(vm) => new MachineListElementView(vm), 
			machines);
			
		_rulesBinding = new BoundList<SecurityRuleModel, SecurityRuleViewModel, SecurityRuleListElementView>(
			(vm) => new SecurityRuleListElementView(vm), 
			rules);
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
			_titleBinding1.binding = null;
			_titleBinding2.binding = null;
			_versionBinding.binding = null;
			_machinesBinding.binding = null;
			_rulesBinding.binding = null;
		}
		else
		{
			_nameBinding.binding = value.name;
			_titleBinding1.binding = value.name;
			_titleBinding2.binding = value.name;
			_versionBinding.binding = value.version;
			_machinesBinding.binding = value.machines;
			_rulesBinding.binding = value.rules;
		}
	}
}