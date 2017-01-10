import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundLabel.dart';
import '../../MVVM/BoundFormatter.dart';
import '../../MVVM/BoundList.dart';
import '../../MVVM/BoundTextInput.dart';
import '../../MVVM/BoundTextArea.dart';

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
	BoundTextArea<String> _configInput;
	BoundList<VariableModel, VariableViewModel, VariableEditView> _variablesList;

	RuleEditView([RuleViewModel viewModel])
	{
		_headingLabel = new BoundLabel<String>(
			addHeading(2, 'Rule Details'), 
			formatMethod: (s) => 'Edit Version ' + _viewModel.version.toString() + ' of ' + s +  ' Rule');

		addBlockText('Each rule must have a name that is unique within this version', className: 'help-note');

		var form1 = addForm();
		_nameInput = new BoundTextInput<String>(addLabeledEdit(form1, 'Unique rule name', className: 'rule-name'));

		addHR();
		addBlockText('Choose where to apply this rule. Leave boxes blank to apply to all.<br>The save button will just save this specific version of this rule.', className: 'help-note');

		var form2 = addForm();
		_instanceInput = new BoundTextInput<String>(addLabeledEdit(form2, 'Applies to instance', className: 'rule-instance'));
		_applicationInput = new BoundTextInput<String>(addLabeledEdit(form2, 'Applies to application', className: 'rule-application'));
		_machineInput = new BoundTextInput<String>(addLabeledEdit(form2, 'Applies to machine', className: 'rule-machine'));
		_environmentInput = new BoundTextInput<String>(addLabeledEdit(form2, 'Applies to environment', className: 'rule-environment'));

		var buttonBar = addContainer(className: 'button-bar');
		addButton("Save", _saveClicked, parent: buttonBar);

		addHR();
		addHeading(3, 'Variables');

		addBlockText(r'Variables can be referenced within the configuration JSON using ($variable$).<br>Note that rules are evaluated twice, once to set all the variables and a second time to merge<br>all the configuration JSON after the variables have all been set.', className: 'help-note');

		_variablesList = new BoundList<VariableModel, VariableViewModel, VariableEditView>(
			(vm) => new VariableEditView(vm), 
			addContainer(className: 'rule-variables'));

		addHR();
		addHeading(3, 'Configuration JSON');

		addBlockText(r'This JSON will be send to the application to configure it.' +
			r'<br>Where multiple rules apply the JSON is merged with more specific rules replacing less specific ones.' +
			r'<br>The value of variables can be inserted by putting the variable name in like this ($variable$).' +
			r'<br>The following variables are pre-defined and are always available: ($machine$) ($application$) ($instance$) ($environment$)', 
			className: 'help-note');

		_configInput = new BoundTextArea<String>(addTextArea(className: 'rule-config'));

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
