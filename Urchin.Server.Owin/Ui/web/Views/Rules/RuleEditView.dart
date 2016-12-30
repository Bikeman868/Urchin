import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundLabel.dart';
import '../../MVVM/BoundFormatter.dart';
import '../../MVVM/BoundList.dart';
import '../../MVVM/BoundTextInput.dart';

import '../../Models/RuleModel.dart';
import '../../Models/VariableModel.dart';

import '../../ViewModels/RuleViewModel.dart';
import '../../ViewModels/VariableViewModel.dart';

import '../../Views/Rules/VariableEditView.dart';

import '../../Events/AppEvents.dart';


class RuleEditView extends View
{
	BoundLabel<String> _headingLabel;
	BoundTextInput<String> _nameInput;
	BoundTextInput<String> _instanceInput;
	BoundTextInput<String> _applicationInput;
	BoundTextInput<String> _machineInput;
	BoundTextInput<String> _environmentInput;
	BoundTextInput<String> _configInput;
	BoundList<VariableModel, VariableViewModel, VariableEditView> _variablesList;

	RuleEditView([RuleViewModel viewModel])
	{
		_headingLabel = new BoundLabel<String>(
			addHeading(2, 'Rule Details'), 
			formatMethod: (s) => 'Version ' + _viewModel.version.toString() + ' of ' + s);

		var form1 = addForm();
		_nameInput = new BoundTextInput<String>(addLabeledEdit(form1, 'Unique rule name'));

		addHR();
		addBlockText('Choose where to apply this rule. Leave blank to apply to all.');

		var form2 = addForm();
		_instanceInput = new BoundTextInput<String>(addLabeledEdit(form2, 'Applies to instance'));
		_applicationInput = new BoundTextInput<String>(addLabeledEdit(form2, 'Applies to application'));
		_machineInput = new BoundTextInput<String>(addLabeledEdit(form2, 'Applies to machine'));
		_environmentInput = new BoundTextInput<String>(addLabeledEdit(form2, 'Applies to environment'));

		var buttonBar = addContainer(className: 'button-bar');
		addButton("Save", _saveClicked, parent: buttonBar);

		addHR();
		addHeading(3, 'Variables');

		_variablesList = new BoundList<VariableModel, VariableViewModel, VariableEditView>(
			(vm) => new VariableEditView(vm), 
			addContainer());

		addHR();
		addHeading(3, 'Configuration JSON');

		_configInput = new BoundTextInput<String>(addTextArea());

		this.viewModel = viewModel;
	}
  
	RuleViewModel _viewModel;
	RuleViewModel get viewModel => _viewModel;

	void set viewModel(RuleViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_headingLabel.binding = null;
			_nameInput.binding = null;
			_instanceInput.binding = null;
			_applicationInput.binding = null;
			_machineInput.binding = null;
			_environmentInput.binding = null;
			_variablesList.binding = null;
			_configInput.binding = null;
		}
		else
		{
			_headingLabel.binding = value.name;
			_nameInput.binding = value.name;
			_instanceInput.binding = value.instance;
			_applicationInput.binding = value.application;
			_machineInput.binding = value.machine;
			_environmentInput.binding = value.environment;
			_variablesList.binding = value.variables;
			_configInput.binding = value.config;
		}
	}

	void _saveClicked(MouseEvent e)
	{
		if (viewModel != null)
			viewModel.save();
	}

}
