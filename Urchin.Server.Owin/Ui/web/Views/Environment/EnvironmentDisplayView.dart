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

class EnvironmentDisplayView extends View
{
	BoundLabel<String> _nameBinding1;
	BoundLabel<String> _nameBinding2;
	BoundLabel<int> _versionBinding;
	BoundList<MachineModel, MachineViewModel, MachineListElementView> _machinesBinding;
	BoundList<SecurityRuleModel, SecurityRuleViewModel, SecurityRuleListElementView> _rulesBinding;

	EnvironmentDisplayView([EnvironmentViewModel viewModel])
	{
		_nameBinding1 = new BoundLabel<String>(
			addHeading(1, 'Environment Details'), 
			formatMethod: (s) => s + ' Environment');

		var versionContainer = addContainer();
		addInlineText('Rules version ', parent: versionContainer);
		_versionBinding = new BoundLabel<int>(addSpan(parent: versionContainer));

		_nameBinding2 = new BoundLabel<String>(
			addHeading(2, 'Environment Computers'), 
			formatMethod: (s) => s + ' Computers');

		_machinesBinding = new BoundList<MachineModel, MachineViewModel, MachineListElementView>(
			(vm) => new MachineListElementView(vm), 
			addContainer(), allowAdd: false, allowRemove: false);
			
		addHeading(2, 'Allowed IP Address Ranges');

		_rulesBinding = new BoundList<SecurityRuleModel, SecurityRuleViewModel, SecurityRuleListElementView>(
			(vm) => new SecurityRuleListElementView(vm), 
			addContainer(), allowAdd: false, allowRemove: false);

		this.viewModel = viewModel;
	}

	EnvironmentViewModel _viewModel;
	EnvironmentViewModel get viewModel => _viewModel;

	void set viewModel(EnvironmentViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_nameBinding1.binding = null;
			_nameBinding2.binding = null;
			_versionBinding.binding = null;
			_machinesBinding.binding = null;
			_rulesBinding.binding = null;
		}
		else
		{
			_nameBinding1.binding = value.name;
			_nameBinding2.binding = value.name;
			_versionBinding.binding = value.version;
			_machinesBinding.binding = value.machines;
			_rulesBinding.binding = value.rules;
		}
	}
}