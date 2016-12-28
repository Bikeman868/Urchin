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
		loaded();
	}

	ChangeState getState()
	{
		return environments.getState();
	}

	void reload()
	{
		Server.getEnvironments()
			.then((List<EnvironmentModel> m) => models = m)
			.catchError((Error error) => window.alert(error.toString()));
	}

	bool _saving;

	bool save([bool alert = true])
	{
		if (_saving) return true;
		_saving = true;

		bool isModified = false;

		var environmentModels = new List<EnvironmentModel>();
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
						environments.saved();
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
			if (alert) window.alert('No changes to save');
		}
	}
}
