import 'dart:html';

import '../../MVVM/Mvvm.dart';

import '../../Models/VariableModel.dart';

import '../../ViewModels/VariableViewModel.dart';

class VariableDisplayView extends View
{
	BoundLabel<String> _nameLabel;
	BoundLabel<String> _valueLabel;

	VariableDisplayView([VariableViewModel viewModel])
	{
		var div = addDiv(className: 'variable');

		_nameLabel = new BoundLabel<String>(
			addSpan(className: 'variable-name', parent: div),
			formatMethod: (s) => r'($' + s + r'$)');

		addInlineText(' = ', parent: div);

		_valueLabel = new BoundLabel<String>(addSpan(className: 'variable-value', parent: div));

		this.viewModel = viewModel;
	}
  
	VariableViewModel _viewModel;
	VariableViewModel get viewModel => _viewModel;

	void set viewModel(VariableViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_nameLabel.binding = null;
			_valueLabel.binding = null;
		}
		else
		{
			_nameLabel.binding = value.name;
			_valueLabel.binding = value.value;
		}
	}
}
