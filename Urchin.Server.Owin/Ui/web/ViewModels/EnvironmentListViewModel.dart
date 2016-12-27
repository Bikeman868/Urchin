import 'dart:html';

import '../MVVM/ModelListBinding.dart';
import '../MVVM/ViewModel.dart';
import '../MVVM/ChangeState.dart';

import '../Models/EnvironmentModel.dart';
import '../ViewModels/EnvironmentViewModel.dart';
import '../Server.dart';

class EnvironmentListViewModel extends ViewModel
{
    ModelListBinding<EnvironmentModel, EnvironmentViewModel> environments;

	EnvironmentListViewModel([List<EnvironmentModel> environmentModels])
	{
		environments = new ModelListBinding<EnvironmentModel, EnvironmentViewModel>(
			(Map json) => new EnvironmentModel(new Map()..['name']='ENVIRONMENT'), 
			(EnvironmentModel m) => new EnvironmentViewModel(m));

		if (environmentModels == null)
			reload();
		else
			models = environmentModels;
	}

	dispose()
	{
		models = null;
	}

	List<EnvironmentModel> get models
	{
		return environments.models;
	}

	void set models(List<EnvironmentModel> value)
	{
		environments.models = value;
	}

	ChangeState getState()
	{
		var state = super.getState();
		if (state != ChangeState.unmodified)
			return state;

		if (environments.getState() != ChangeState.unmodified)
			return ChangeState.modified;

		return ChangeState.unmodified;
	}

	void reload()
	{
		Server.getEnvironments()
			.then((List<EnvironmentModel> m) => models = m)
			.catchError((Error error) => window.alert(error.toString()));
	}

	bool _saving;

	void save()
	{
		if (_saving) return;
		_saving = true;

		var environmentModels = new List<EnvironmentModel>();
		bool isModified = false;
		for (EnvironmentViewModel environmentViewModel in environments.viewModels)
		{
			var state = environmentViewModel.getState();
			if (state != ChangeState.deleted)
				environmentModels.add(environmentViewModel.model);
			if (state != ChangeState.unmodified)
				isModified = true;
		}
		if (isModified)
		{
			Server.replaceEnvironments(environmentModels)
				.then((error)
				{
					_saving = false;
					if (error == null)
					{
						saved();
						for (EnvironmentViewModel environmentViewModel in environments.viewModels)
							environmentViewModel.saved();
						window.alert('Environments saved');
					}
					else
						window.alert('Environments were not saved. ' + error);
				})
				.catchError((Error error)
				{
					_saving = false;
					window.alert(error.toString());
				});
		}
		else
		{
			window.alert('No changes to save');
		}
	}
}
