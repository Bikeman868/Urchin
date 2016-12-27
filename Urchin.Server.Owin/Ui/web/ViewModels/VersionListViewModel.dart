import 'dart:html';
import 'dart:async';

import '../MVVM/ModelListBinding.dart';
import '../MVVM/ViewModel.dart';
import '../MVVM/ChangeState.dart';

import '../Models/VersionModel.dart';
import '../ViewModels/VersionViewModel.dart';
import '../ViewModels/EnvironmentListViewModel.dart';
import '../Server.dart';

class VersionListViewModel extends ViewModel
{
    ModelListBinding<VersionModel, VersionViewModel> versions;

	VersionListViewModel([List<VersionModel> versionModels])
	{
		versions = new ModelListBinding<VersionModel, VersionViewModel>(
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
	}

	EnvironmentListViewModel _environmentListViewModel;
	void set environmentViewModels(EnvironmentListViewModel value)
	{
		_environmentListViewModel = value;
		environments.models  = value.models;
	}

	ChangeState getState()
	{
		var state = super.getState();
		if (state != ChangeState.unmodified)
			return state;

		if (versions.getState() != ChangeState.unmodified)
			return ChangeState.modified;

		return ChangeState.unmodified;
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
			.catchError((Error error) => window.alert(error.toString()));
	}


	bool _saving;

	void save()
	{
		if (_saving) return;
		_saving = true;

		for (VersionViewModel versionViewModel in versions.viewModels)
		{
			var versionModel = versionViewModel.model;
			var state = versionViewModel.getState();
			if (state == ChangeState.deleted)
			{
				Server.deleteVersion(versionModel.version) /*
					.then((HttpRequest) request
						{
							if (request.status != 200)
							{
								window.alert('Failed to delete version ' + versionModel.version + ' ' + request.statusText);
								_saving = false;
								return;
							}
							versionViewModel.saved();
						}) */
					.catchError((Error error) => window.alert(error.toString()));
			}
			else if (state == ChangeState.modified || state == ChangeState.added)
			{
				Server.updateVersion(versionModel.version, versionModel) /*
					.then((HttpRequest) request
						{
							if (request.status != 200)
							{
								window.alert('Failed to update version ' + versionModel.version + ' ' + request.statusText);
								_saving = false;
								return;
							}
							versionViewModel.saved();
						}) */
					.catchError((Error error) => window.alert(error.toString()));
			}
		}
		saved();
		_saving = false;
	}
}
