import 'dart:async';

import '../MVVM/Mvvm.dart';

import '../Models/ApplicationModel.dart';
import '../Models/PostResponseModel.dart';

import '../ViewModels/ApplicationViewModel.dart';

import '../Server.dart';

class ApplicationListViewModel extends ViewModel
{
    ModelList<ApplicationModel, ApplicationViewModel> applications;

	ApplicationListViewModel([List<ApplicationModel> applicationModels]): super(false)
	{
		applications = new ModelList<ApplicationModel, ApplicationViewModel>(
			(Map json) => new ApplicationModel(new Map()..['name']='APP'), 
			(ApplicationModel m) => new ApplicationViewModel(m));

		if (applicationModels == null)
			reload();
		else
			models = applicationModels;
	}

	dispose()
	{
		models = null;
	}

	List<ApplicationModel> get models
	{
		return applications.models;
	}

	void set models(List<ApplicationModel> value)
	{
		applications.models = value;
		loaded();
	}

	List<ModelList> getModelLists()
	{
		return [applications];
	}

	void reload()
	{
		Server.getApplications()
			.then((List<ApplicationModel> m) => models = m)
			.catchError((Error error) => MvvmEvents.alert.raise(error.toString()));
	}

	Future<SaveResult> saveChanges(ChangeState state, bool alert) async
	{
		List<ApplicationViewModel> viewModels = applications.viewModels
			.where((ApplicationViewModel vm) => vm != null && vm.getState() != ChangeState.deleted)
			.toList();

		viewModels.forEach((ApplicationViewModel vm) => vm.removeDeleted());

		List<ApplicationModel> applicationModels = applications.viewModels
			.map((ApplicationViewModel vm) => vm.model)
			.toList();

		PostResponseModel response = await Server.replaceApplications(applicationModels);

		if (response.success)
		{
			viewModels.forEach((ApplicationViewModel vm) => vm.saved());
			if (alert) MvvmEvents.alert.raise('Applications saved succesfully');
			return SaveResult.saved;
		}

		MvvmEvents.alert.raise('Applications were not saved. ' + response.error);
		return SaveResult.failed;
	}

	String toString() => 'application list view model';
}
