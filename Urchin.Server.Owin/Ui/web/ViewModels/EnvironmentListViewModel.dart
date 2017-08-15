import 'dart:html';
import 'dart:async';

import '../MVVM/Mvvm.dart';

import '../Models/EnvironmentModel.dart';
import '../Models/PostResponseModel.dart';

import '../ViewModels/EnvironmentViewModel.dart';

import '../Server.dart';

class EnvironmentListViewModel extends ViewModel
{
    ModelList<EnvironmentModel, EnvironmentViewModel> environments;

	EnvironmentListViewModel([List<EnvironmentModel> environmentModels]): super(false)
	{
		environments = new ModelList<EnvironmentModel, EnvironmentViewModel>(
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

	List<ModelList> getModelLists()
	{
		return [environments];
	}

	void reload()
	{
		Server.getEnvironments()
			.then((List<EnvironmentModel> m) => models = m)
			.catchError((Error error) => MvvmEvents.alert.raise(error.toString()));
	}

	Future<SaveResult> saveChanges(ChangeState state, bool alert) async
	{
		List<EnvironmentViewModel> viewModels = environments.viewModels
			.where((EnvironmentViewModel vm) => vm != null && vm.getState() != ChangeState.deleted)
			.toList();

		viewModels.forEach((EnvironmentViewModel vm) => vm.removeDeleted());

		List<EnvironmentModel> environmentModels = environments.viewModels
			.map((EnvironmentViewModel vm) => vm.model)
			.toList();

		PostResponseModel response = await Server.replaceEnvironments(environmentModels);

		if (response.success)
		{
			viewModels.forEach((EnvironmentViewModel vm) => vm.saved());
			if (alert) MvvmEvents.alert.raise('Environments saved succesfully');
			return SaveResult.saved;
		}

		MvvmEvents.alert.raise('Environments were not saved. ' + response.error);
		return SaveResult.failed;
	}

	String toString() => 'environment list view model';
}
