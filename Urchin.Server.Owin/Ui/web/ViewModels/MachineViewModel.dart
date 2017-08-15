import 'dart:async';

import '../MVVM/Mvvm.dart';

import '../Models/MachineModel.dart';

class MachineViewModel extends ViewModel
{
    StringBinding name = new StringBinding();

	MachineViewModel([MachineModel model])
	{
		this.model = model;
	}

	dispose()
	{
		model = null;
	}

	MachineModel _model;
	MachineModel get model => _model;

	void set model(MachineModel value)
	{
		_model = value;

		if (value == null)
		{
			name.setter = null;
			name.getter = null;
		}
		else
		{
			name.setter = (String text) 
			{ 
				value.name = text; 
				modified();
			};
			name.getter = () => value.name;
		}
		loaded();
	}

	Future<SaveResult> saveChanges(ChangeState state, bool alert) async
	{
		return SaveResult.notsaved;
	}

	String toString() => _model.toString() + ' view model';
}