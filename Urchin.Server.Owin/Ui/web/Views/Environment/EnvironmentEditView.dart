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
	BoundList<SecurityRuleModel, SecurityRuleViewModel, SecurityRuleEditView> _securityRulesBinding;

	EnvironmentEditView([EnvironmentViewModel viewModel])
	{
		_titleBinding1 = new BoundLabel<String>(
			addHeading(2, 'Environment Details'), 
			formatMethod: (s) => 'Edit ' + s + ' Environment');

		addBlockText('An environment is a group of computers that have some shared configuration.' +
			'<br>Each environment uses a specific version of the rules. This allows you' +
			'<br>to test rule changes before applying them to the production environment' +
			'<br>or keep configuration in sync with code changes as builds are pushed to' +
			'<br>different environments'
			, className: 'help-note');

		var form = addForm();
		_nameBinding = new BoundTextInput<String>(addLabeledEdit(form, 'Environment name'));
		_versionBinding = new BoundTextInput<int>(addLabeledEdit(form, 'Version of rules'));

		// var buttonBar = addContainer(className: 'button-bar');
		// addButton("Save", _saveClicked, parent: buttonBar);
		// addButton("Discard", _discardClicked, parent: buttonBar);

		addHR();

		_titleBinding2 = new BoundLabel<String>(
			addHeading(3, 'Environment Computers'), 
			formatMethod: (s) => s + ' environment computers');

		addBlockText('These computers will use this environment\'s configuration by default', className: 'help-note');

		_machinesBinding = new BoundList<MachineModel, MachineViewModel, MachineEditView>(
			(vm) => new MachineEditView(vm), 
			addContainer());

		addHR();

		addHeading(3, 'Allowed IP Address Ranges');

		addBlockText('Only computers with allowed IP addresses will be able to retrieve configuration' +
			'<br>for this environment'
			, className: 'help-note');
			
		_securityRulesBinding = new BoundList<SecurityRuleModel, SecurityRuleViewModel, SecurityRuleEditView>(
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
			_securityRulesBinding.binding = null;
		}
		else
		{
			_nameBinding.binding = value.name;
			_titleBinding1.binding = value.name;
			_titleBinding2.binding = value.name;
			_versionBinding.binding = value.version;
			_machinesBinding.binding = value.machines;
			_securityRulesBinding.binding = value.securityRules;
		}
	}

}