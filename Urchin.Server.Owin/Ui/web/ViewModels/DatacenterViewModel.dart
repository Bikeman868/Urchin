import 'dart:async';

import '../MVVM/Mvvm.dart';

import '../Models/DatacenterModel.dart';

class DatacenterViewModel extends ViewModel
{
	StringBinding name = new StringBinding();

	DatacenterViewModel([DatacenterModel model])
	{
		this.model = model;
	}

	dispose()
	{
		model = null;
	}

	DatacenterModel _model;
	DatacenterModel get model => _model;

	void set model(DatacenterModel value)
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