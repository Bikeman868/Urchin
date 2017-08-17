import 'dart:html';
import 'dart:async';

import '../MVVM/Mvvm.dart';

import '../Models/VersionModel.dart';
import '../ViewModels/VersionViewModel.dart';
import '../ViewModels/EnvironmentListViewModel.dart';
import '../Server.dart';

class VersionListViewModel extends ViewModel
{
    ModelList<VersionModel, VersionViewModel> versions;

	VersionListViewModel([List<VersionModel> versionModels]): super(false)
	{
		versions = new ModelList<VersionModel, VersionViewModel>(
			(Map json) => new VersionModel(new Map()..['name']='VERSION', false), 
			(VersionModel m) => new VersionViewModel(m));

		if (versionModels == null)
			reload();
		else
			models = versionModels;
	}

	dispose()
	{
		models = null;
	}

	List<VersionModel> get models
	{
		return versions.models;
	}

	void set models(List<VersionModel> value)
	{
		versions.models = value;
		loaded();
	}

	// EnvironmentListViewModel _environmentListViewModel;
	void set environmentViewModels(EnvironmentListViewModel value)
	{
		// _environmentListViewModel = value;
		// versions.models  = value.models;
	}

	List<ModelList> getModelLists()
	{
		return [versions];
	}

	Future<Null> ensureRules(VersionViewModel versionViewModel) async
	{
		var versionModel = versionViewModel.model;
		if (versionModel != null && !versionModel.hasRules)
		{
			var versionWithRules = await Server.getRules(versionModel.version);
			versionModel.rules = versionWithRules.rules;
			versionViewModel.model = versionModel;
		}
	}

	void reload()
	{
		Server.getVersions()
			.then((List<VersionModel> m) => models = m)
			.catchError((Error error) => MvvmEvents.alert.raise(error.toString()));
	}

	Future<VersionViewModel> getDraftVersion() async
	{
		VersionModel draftVersionModel = await Server.getDraftRules();
		for (var versionViewModel in versions.viewModels)
		{
			if (draftVersionModel.version == versionViewModel.model.version)
				return versionViewModel;
		}
		return versions.addModel(draftVersionModel);
	}

	String toString() => 'version list view model';
}
