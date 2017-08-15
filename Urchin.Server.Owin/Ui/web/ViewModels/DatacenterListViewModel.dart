import 'dart:async';

import '../MVVM/Mvvm.dart';

import '../Models/DatacenterModel.dart';
import '../Models/PostResponseModel.dart';

import '../ViewModels/DatacenterViewModel.dart';

import '../Server.dart';

class DatacenterListViewModel extends ViewModel
{
	ModelList<DatacenterModel, DatacenterViewModel> datacenters;

	DatacenterListViewModel([List<DatacenterModel> datacenterModels]): super(false)
	{
		datacenters = new ModelList<DatacenterModel, DatacenterViewModel>(
			(Map json) => new DatacenterModel(new Map()..['name']='mycompany:datacenter1'), 
			(DatacenterModel m) => new DatacenterViewModel(m));

		if (datacenterModels == null)
			reload();
		else
			models = datacenterModels;
	}

	dispose()
	{
		models = null;
	}

	List<DatacenterModel> get models
	{
		return datacenters.models;
	}

	void set models(List<DatacenterModel> value)
	{
		datacenters.models = value;
		loaded();
	}

	List<ModelList> getModelLists()
	{
		return [datacenters];
	}

	void reload()
	{
		Server.getDatacenters()
			.then((List<DatacenterModel> m) => models = m)
			.catchError((Error error) => MvvmEvents.alert.raise(error.toString()));
	}

	Future<SaveResult> saveChanges(ChangeState state, bool alert) async
	{
		List<DatacenterViewModel> viewModels = datacenters.viewModels
			.where((DatacenterViewModel vm) => vm != null && vm.getState() != ChangeState.deleted)
			.toList();

		viewModels.forEach((DatacenterViewModel vm) => vm.removeDeleted());

		List<DatacenterModel> datacenterModels = datacenters.viewModels
			.map((DatacenterViewModel vm) => vm.model)
			.toList();

		PostResponseModel response = await Server.replaceDatacenters(datacenterModels);

		if (response.success)
		{
			viewModels.forEach((DatacenterViewModel vm) => vm.saved());
			if (alert) MvvmEvents.alert.raise('Datacenters saved succesfully');
			return SaveResult.saved;
		}

		MvvmEvents.alert.raise('Datacenters were not saved. ' + response.error);
		return SaveResult.failed;
	}

	String toString() => 'datacenter list view model';
}
