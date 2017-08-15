import 'dart:html';

import '../../MVVM/Mvvm.dart';

import '../../Models/MachineModel.dart';
import '../../Models/SecurityRuleModel.dart';

import '../../ViewModels/EnvironmentViewModel.dart';
import '../../ViewModels/MachineViewModel.dart';
import '../../ViewModels/SecurityRuleViewModel.dart';

import '../../Views/Machine/MachineNameView.dart';
import '../../Views/Machine/MachineNameView.dart';
import '../../Views/SecurityRule/SecurityRuleListElementView.dart';

class EnvironmentDisplayView extends View
{
	BoundLabel<String> _nameBinding1;
	BoundLabel<String> _nameBinding2;
	BoundLabel<int> _versionBinding;
	BoundRepeater<MachineModel, MachineViewModel, MachineNameView> _machinesBinding;
	BoundList<SecurityRuleModel, SecurityRuleViewModel, SecurityRuleListElementView> _securityRulesBinding;

	EnvironmentDisplayView([EnvironmentViewModel viewModel])
	{
		_nameBinding1 = new BoundLabel<String>(
			addHeading(2, 'Environment Details'), 
			formatMethod: (s) => s + ' Environment');

		var versionContainer = addContainer();
		addInlineText('Rules version ', parent: versionContainer);
		_versionBinding = new BoundLabel<int>(addSpan(parent: versionContainer));

		_nameBinding2 = new BoundLabel<String>(
			addHeading(3, 'Environment Computers'), 
			formatMethod: (s) => s + ' Computers');

		_machinesBinding = new BoundRepeater<MachineModel, MachineViewModel, MachineNameView>(
			(vm) => new MachineNameView(vm), 
			addContainer());
			
		addHeading(3, 'Allowed IP Address Ranges');

		_securityRulesBinding = new BoundList<SecurityRuleModel, SecurityRuleViewModel, SecurityRuleListElementView>(
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
			_securityRulesBinding.binding = null;
		}
		else
		{
			_nameBinding1.binding = value.name;
			_nameBinding2.binding = value.name;
			_versionBinding.binding = value.version;
			_machinesBinding.binding = value.machines;
			_securityRulesBinding.binding = value.securityRules;
		}
	}
}