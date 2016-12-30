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
		List<EnvironmentModel> environmentModels = environments.viewModels
			.where((EnvironmentViewModel vm) => vm.getState() != ChangeState.deleted)
			.map((EnvironmentViewModel vm) => vm.model)
			.toList();

		PostResponseModel response = await Server.replaceEnvironments(environmentModels);

		if (response.success)
		{
			if (alert) window.alert('Environments saved succesfully');
			return SaveResult.saved;
		}

		if (alert) window.alert('Environments were not saved. ' + response.error);
		return SaveResult.failed;
	}
}
