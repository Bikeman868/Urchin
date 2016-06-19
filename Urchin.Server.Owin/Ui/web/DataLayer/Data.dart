import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../DataLayer/VersionData.dart';
import '../Server.dart';
import '../DataBinding/ChangeState.dart';

import '../Models/DataModel.dart';
import '../Models/VersionModel.dart';
import '../Models/EnvironmentModel.dart';

import '../ViewModels/DataViewModel.dart';
import '../ViewModels/EnvironmentViewModel.dart';

import '../Events/AppEvents.dart';
import '../Events/SubscriptionEvent.dart';

class Data
{
	DataViewModel viewModel;

	Map<int, VersionData> _versionDataMap;
	List<VersionModel> _versionModelList;

	Data()
	{
		viewModel = new DataViewModel();

		_versionDataMap = new Map<int, VersionData>();
		AppEvents.userChanged.listen(_userChanged);
	}

	reload() async
	{
		await _load();
		_versionModelList = null;

		for(var version in _versionDataMap.values)
			version.reload();

		AppEvents.dataLoadedEvent.raise(new DataEvent(this));
	}

	save() async
	{
		for(var version in _versionDataMap.values)
			if (!await version.save())
				return;

		if (!await _save())
			return;

		AppEvents.dataSavedEvent.raise(new DataEvent(this));
	}

	Future<bool> _save() async
	{
		var environmentList = viewModel.environments;

		var environmentModels = new List<EnvironmentModel>();
		bool isModified = false;
		for (EnvironmentViewModel environmentViewModel in environmentList.viewModels)
		{
			var state = environmentViewModel.getState();
			if (state != ChangeState.deleted)
				environmentModels.add(environmentViewModel.model);
			if (state != ChangeState.unmodified)
				isModified = true;
		}
		if (!isModified) return true;

		String error = await Server.replaceEnvironments(environmentModels);
		if (error == null) return true;
		window.alert('Changes were not saved. ' + error);
		return false;
	}

	_load() async
	{
		var model = new DataModel();

		model.environments = await Server.getEnvironments();
		model.versions = null;

		viewModel.model = model;
	}

	Future<List<VersionModel>> getVersions() async
	{
		if (_versionModelList == null)
		{
			_versionModelList = await Server.getVersions();
		}
		return _versionModelList;
	}

	Future<VersionData> getVersion(int version) async
	{
		VersionData result = _versionDataMap[version];
		if (result == null)
		{
			var versions = await getVersions();
			for (var versionModel in versions)
			{
				if (versionModel.version == version)
				{
					result = new VersionData(versionModel);
					_versionDataMap[version] = result;
				}
			}
		}
		return result;
	}

	void _userChanged(UserChangedEvent e)
	{
		reload();
	}
}
