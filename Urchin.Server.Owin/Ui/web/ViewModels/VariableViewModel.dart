import 'dart:async';

import '../MVVM/StringBinding.dart';
import '../MVVM/ViewModel.dart';
import '../MVVM/Enums.dart';

import '../Models/VariableModel.dart';

class VariableViewModel extends ViewModel
{
    StringBinding name = new StringBinding();
    StringBinding value = new StringBinding();

	VariableViewModel([VariableModel model])
	{
		this.model = model;
	}

	dispose()
	{
		model = null;
	}

	VariableModel _model;
	VariableModel get model => _model;

	void set model(VariableModel value)
	{
		_model = value;

		if (value == null)
		{
			name.setter = null;
			name.getter = null;

			this.value.setter = null;
			this.value.getter = null;
		}
		else
		{
			name.setter = (String text) 
			{ 
				value.name = text; 
				modified();
			};
			name.getter = () => value.name;

			this.value.setter = (String text) 
			{ 
				value.value = text; 
				modified();
			};
			this.value.getter = () => value.value;
		}
		loaded();
	}

	Future<SaveResult> saveChanges(ChangeState state, bool alert) async
	{
		return SaveResult.notsaved;
	}

	String toString() => _model.toString() + ' view model';
}