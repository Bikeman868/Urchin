import 'dart:html';
import 'dart:async';

import '../MVVM/ModelListBinding.dart';
import '../MVVM/ViewModel.dart';
import '../MVVM/Enums.dart';

import '../Models/EnvironmentModel.dart';
import '../Models/PostResponseModel.dart';

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

	List<ModelListBinding> getModelLists()
	{
		return [environments];
	}

	void reload()
	{
		Server.getEnvironments()
			.then((List<EnvironmentModel> m) => models = m)
			.catchError((Error error) => window.alert(error.toString()));
	}

	Future<SaveResult> saveChanges(ChangeState state, bool alert) async
	{
		SaveResult result = SaveResult.unmodified;

		var environmentModels = new List<EnvironmentModel>();
		for (EnvironmentViewModel environmentViewModel in environments.viewModels)
		{
			var environmentState = environmentViewModel.getState();
			if (environmentState != ChangeState.deleted)
				environmentModels.add(environmentViewModel.model);
			if (environmentState != ChangeState.unmodified)
				result = SaveResult.notsaved;
		}

		String alertMessage = 'There are no changes to the list of environments';
		if (result != SaveResult.unmodified)
		{
			PostResponseModel response = await Server.replaceEnvironments(environmentModels);
			if (response.success)
			{
				alertMessage = 'Environments saved succesfully';
				result = SaveResult.saved;
			}
			else
			{
				alertMessage = 'Environments were not saved. ' + response.error;
				result = SaveResult.failed;
			}
		}

		if (alert) window.alert(alertMessage);
		return result;
	}
}
