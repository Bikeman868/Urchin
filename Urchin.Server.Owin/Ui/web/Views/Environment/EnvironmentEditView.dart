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

import '../../Views/Machine/MachineEditView.dart';
import '../../Views/SecurityRule/SecurityRuleEditView.dart';

class EnvironmentEditView extends View
{
	BoundTextInput<String> _nameBinding;
	BoundLabel<String> _titleBinding1;
	BoundLabel<String> _titleBinding2;
	BoundTextInput<int> _versionBinding;
	BoundList<MachineModel, MachineViewModel, MachineEditView> _machinesBinding;
	BoundList<SecurityRuleModel, SecurityRuleViewModel, SecurityRuleEditView> _rulesBinding;

	EnvironmentEditView([EnvironmentViewModel viewModel])
	{
		_titleBinding1 = new BoundLabel<String>(
			addHeading(1, 'Environment Details'), 
			formatMethod: (s) => s + ' Environment');

		var form = addForm();
		_nameBinding = new BoundTextInput<String>(addLabeledEdit(form, 'Environment name'));
		_versionBinding = new BoundTextInput<int>(addLabeledEdit(form, 'Version of rules'));

		_titleBinding2 = new BoundLabel<String>(
			addHeading(2, 'Environment Computers'), 
			formatMethod: (s) => s + ' Computers');

		_machinesBinding = new BoundList<MachineModel, MachineViewModel, MachineEditView>(
			(vm) => new MachineEditView(vm), 
			addContainer());

		addHeading(2, 'Allowed IP Address Ranges');
			
		_rulesBinding = new BoundList<SecurityRuleModel, SecurityRuleViewModel, SecurityRuleEditView>(
			(vm) => new SecurityRuleEditView(vm), 
			addContainer());

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