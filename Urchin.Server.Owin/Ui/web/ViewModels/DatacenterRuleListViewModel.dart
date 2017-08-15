import 'dart:async';

import '../MVVM/Mvvm.dart';

import '../Models/DatacenterRuleModel.dart';
import '../Models/PostResponseModel.dart';

import '../ViewModels/DatacenterRuleViewModel.dart';

import '../Server.dart';

class DatacenterRuleListViewModel extends ViewModel
{
	ModelList<DatacenterRuleModel, DatacenterRuleViewModel> datacenterRules;

	DatacenterRuleListViewModel([List<DatacenterRuleModel> datacenterRuleModels]): super(false)
	{
		datacenterRules = new ModelList<DatacenterRuleModel, DatacenterRuleViewModel>(
			(Map json) => new DatacenterRuleModel(new Map()), 
			(DatacenterRuleModel m) => new DatacenterRuleViewModel(m));

		if (datacenterRuleModels == null)
			reload();
		else
			models = datacenterRuleModels;
	}

	dispose()
	{
		models = null;
	}

	List<DatacenterRuleModel> get models
	{
		return datacenterRules.models;
	}

	void set models(List<DatacenterRuleModel> value)
	{
		datacenterRules.models = value;
		loaded();
	}

	List<ModelList> getModelLists()
	{
		return [datacenterRules];
	}

	void reload()
	{
		Server.getDatacenterRules()
			.then((List<DatacenterRuleModel> m) => models = m)
			.catchError((Error error) => MvvmEvents.alert.raise(error.toString()));
	}

	Future<SaveResult> saveChanges(ChangeState state, bool alert) async
	{
		List<DatacenterRuleViewModel> viewModels = datacenterRules.viewModels
			.where((DatacenterRuleViewModel vm) => vm != null && vm.getState() != ChangeState.deleted)
			.toList();

		viewModels.forEach((DatacenterRuleViewModel vm) => vm.removeDeleted());

		List<DatacenterRuleModel> datacenterRuleModels = datacenterRules.viewModels
			.map((DatacenterRuleViewModel vm) => vm.model)
			.toList();

		PostResponseModel response = await Server.replaceDatacenterRules(datacenterRuleModels);

		if (response.success)
		{
			viewModels.forEach((DatacenterRuleViewModel vm) => vm.saved());
			if (alert) MvvmEvents.alert.raise('Datacenter rules saved succesfully');
			return SaveResult.saved;
		}

		MvvmEvents.alert.raise('Datacenter rules were not saved. ' + response.error);
		return SaveResult.failed;
	}

	String toString() => 'datacenter rule list view model';
}
