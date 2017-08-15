import 'dart:html';

import '../../MVVM/Mvvm.dart';

import '../../Html/JsonHighlighter.dart';

import '../../Models/RuleModel.dart';
import '../../Models/VariableModel.dart';

import '../../ViewModels/RuleViewModel.dart';
import '../../ViewModels/VariableViewModel.dart';

import '../../Views/Rules/VariableDisplayView.dart';

import '../../Events/AppEvents.dart';


class RuleConfigView extends View
{
	BoundLabel<String> _ruleNameLabel;
	BoundLabel<String> _machineLabel;
	BoundLabel<String> _environmentLabel;
	BoundLabel<String> _instanceLabel;
	BoundLabel<String> _applicationLabel;
	BoundFormatter _formattedConfig;
	BoundRepeater<VariableModel, VariableViewModel, VariableDisplayView> _variablesList;

	RuleConfigView([RuleViewModel viewModel])
	{
		_ruleNameLabel = new BoundLabel<String>(
			addHeading(2, 'Rule Details'), 
			formatMethod: (s) => 'Version ' + _viewModel.version.toString() + ' of ' + s + ' Rule');

		addInlineText('This rule applies to');

		_instanceLabel = new BoundLabel<String>(addSpan(), 
			formatMethod: (s)
			{
				if (s == null || s.length == 0)
					return ' all instances';
				return ' the ' + s + ' instance';
			});

		_applicationLabel = new BoundLabel<String>(addSpan(), 
			formatMethod: (s)
			{
				if (s == null || s.length == 0)
					return ' of all applications';
				return ' of the ' + s + ' application';
			});

		_machineLabel = new BoundLabel<String>(addSpan(), 
			formatMethod: (s)
			{
				if (s == null || s.length == 0)
					return ' running on any computer';
				return ' running on ' + s;
			});

		_environmentLabel = new BoundLabel<String>(addSpan(), 
			formatMethod: (s)
			{
				if (s == null || s.length == 0)
					return ' in any environment';
				return ' in the ' + s + ' environment';
			});

		_formattedConfig = new BoundFormatter(addDiv(), (s, e) => JsonHighlighter.displayIn(e, s));

		_variablesList = new BoundRepeater<VariableModel, VariableViewModel, VariableDisplayView>(
			(vm) => new VariableDisplayView(vm), 
			addContainer(className: 'variable-list'));

		this.viewModel = viewModel;
	}
  
	RuleViewModel _viewModel;
	RuleViewModel get viewModel => _viewModel;

	void set viewModel(RuleViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_ruleNameLabel.binding = null;
			_machineLabel.binding = null;
			_environmentLabel.binding = null;
			_instanceLabel.binding = null;
			_applicationLabel.binding = null;
			_formattedConfig.binding = null;
			_variablesList.binding = null;
		}
		else
		{
			_ruleNameLabel.binding = value.name;
			_machineLabel.binding = value.machine;
			_environmentLabel.binding = value.environment;
			_instanceLabel.binding = value.instance;
			_applicationLabel.binding = value.application;
			_formattedConfig.binding = value.config;
			_variablesList.binding = value.variables;
		}
	}
}
