import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundLabel.dart';
import '../../MVVM/BoundFormatter.dart';
import '../../MVVM/BoundRepeater.dart';

import '../../Html/JsonHighlighter.dart';

import '../../Models/RuleModel.dart';
import '../../Models/VariableModel.dart';

import '../../ViewModels/RuleViewModel.dart';
import '../../ViewModels/VariableViewModel.dart';

import '../../Views/Rules/VariableNameView.dart';

import '../../Events/AppEvents.dart';


class RuleEditView extends View
{
	BoundLabel<String> _ruleName;
	BoundLabel<String> _machine;
	BoundLabel<String> _environment;
	BoundLabel<String> _instance;
	BoundLabel<String> _application;
	BoundFormatter _config;
	BoundRepeater<VariableModel, VariableViewModel, VariableNameView> _variablesBinding;

	RuleEditView([RuleViewModel viewModel])
	{
		_ruleName = new BoundLabel<String>(
			addHeading(2, 'Rule Details'), 
			formatMethod: (s) => s + ' Rule V' + _viewModel.version.toString());

		addInlineText('This rule applies to');

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
		addButton("Save", _saveClicked, parent: buttonBar);

		addHeading(3, 'Variables');

		_variablesBinding = new BoundRepeater<VariableModel, VariableViewModel, VariableNameView>(
			(vm) => new VariableNameView(vm), 
			addContainer());

		addHR();

		addHeading(3, 'JSON Data');

		_config = new BoundFormatter(addDiv(), (s, e) => JsonHighlighter.displayIn(e, s));

		this.viewModel = viewModel;
	}
  
	RuleViewModel _viewModel;
	RuleViewModel get viewModel => _viewModel;

	void set viewModel(RuleViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_ruleName.binding = null;
			_machine.binding = null;
			_environment.binding = null;
			_instance.binding = null;
			_application.binding = null;
			_config.binding = null;
			_variablesBinding.binding = null;
		}
		else
		{
			_ruleName.binding = value.name;
			_machine.binding = value.machine;
			_environment.binding = value.environment;
			_instance.binding = value.instance;
			_application.binding = value.application;
			_config.binding = value.config;
			_variablesBinding.binding = value.variables;
		}
	}

	void _saveClicked(MouseEvent e)
	{
		if (viewModel != null)
			viewModel.save();
	}

}
