import 'dart:html';

import '../../MVVM/Mvvm.dart';

import '../../Models/VariableModel.dart';

import '../../ViewModels/VariableViewModel.dart';

class VariableNameView extends View
{
	BoundLabel<String> _name;

	VariableNameView([VariableViewModel viewModel])
	{
		_name = new BoundLabel<String>(
			addSpan(className: 'variable-name'),
			formatMethod: (s) => r'($' + s + r'$) ');
		this.viewModel = viewModel;
	}
  
	VariableViewModel _viewModel;
	VariableViewModel get viewModel => _viewModel;

	void set viewModel(VariableViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_name.binding = null;
		}
		else
		{
			_name.binding = value.name;
		}
	}
}
