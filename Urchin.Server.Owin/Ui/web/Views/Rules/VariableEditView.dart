import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundTextInput.dart';

import '../../Models/VariableModel.dart';

import '../../ViewModels/VariableViewModel.dart';

class VariableEditView extends View
{
	BoundTextInput<String> _nameInput;
	BoundTextInput<String> _valueInput;

	VariableEditView([VariableViewModel viewModel])
	{
		var div = addDiv(className: 'variable-edit');

		_nameInput = new BoundTextInput<String>(addInput(classNames: ['variable-name', 'input-field'], parent: div));
		_valueInput = new BoundTextInput<String>(addTextArea(classNames: ['variable-value', 'input-field'], parent: div));

		this.viewModel = viewModel;
	}
  
	VariableViewModel _viewModel;
	VariableViewModel get viewModel => _viewModel;

	void set viewModel(VariableViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_nameInput.binding = null;
			_valueInput.binding = null;
		}
		else
		{
			_nameInput.binding = value.name;
			_valueInput.binding = value.value;
		}
	}
}
