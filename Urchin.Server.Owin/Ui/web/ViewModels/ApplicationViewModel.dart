import 'dart:async';

import '../MVVM/Mvvm.dart';

import '../Models/ApplicationModel.dart';

class ApplicationViewModel extends ViewModel
{
	StringBinding name = new StringBinding();

	ApplicationViewModel([ApplicationModel model])
	{
		this.model = model;
	}

	dispose()
	{
		model = null;
	}

	ApplicationModel _model;
	ApplicationModel get model => _model;

	void set model(ApplicationModel value)
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