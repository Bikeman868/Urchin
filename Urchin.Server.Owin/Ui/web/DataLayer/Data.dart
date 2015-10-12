import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../DataLayer/VersionData.dart';
import '../Server.dart';

import '../Models/VersionModel.dart';
import '../Models/EnvironmentModel.dart';

import '../ViewModels/EnvironmentViewModel.dart';

import '../Events/AppEvents.dart';
import '../Events/SubscriptionEvent.dart';

class Data
{
	Map<int, VersionData> _versionDataMap;
	Map<String, EnvironmentViewModel> _environmentViewModelMap;
	List<VersionModel> _versionModelList;

	Data()
	{
		_versionDataMap = new Map<int, VersionData>();
		AppEvents.userChanged.listen(_userChanged);
	}

	reload() async
	{
		await _loadEnvironments();
		_versionModelList = null;

		for(var version in _versionDataMap.values)
			version.reload();

		AppEvents.dataLoadedEvent.raise(new DataEvent(this));
	}

	save() async
	{
		for(var version in _versionDataMap.values)
			version.save();

		await _saveEnvironments();

		AppEvents.dataSavedEvent.raise(new DataEvent(this));
	}

	_saveEnvironments() async
	{
	}

	_loadEnvironments() async
	{
		List<String> deletedEnvironmentNames = new List<String>();

		List<EnvironmentModel> environmentModelList = await Server.getEnvironments();
		if (_environmentViewModelMap == null)
		{
			_environmentViewModelMap = new Map<String, EnvironmentViewModel>();
		}
		else
		{
			for (var name in _environmentViewModelMap.keys)
			{
				if (!environmentModelList.any((EnvironmentModel m) => m.name == name))
					deletedEnvironmentNames.add(name);
			}
		}

		for (EnvironmentModel model in environmentModelList)
		{
			String name = model.name;
			EnvironmentViewModel viewModel = _environmentViewModelMap[name];
			if (viewModel == null)
			{
				if (deletedEnvironmentNames.length > 0)
				{
					var oldName = deletedEnvironmentNames[0];
					deletedEnvironmentNames.removeAt(0);
					viewModel = _environmentViewModelMap[oldName];
					_environmentViewModelMap.remove(oldName);
				}
				else
				{
					viewModel = new EnvironmentViewModel();
				}
				_environmentViewModelMap[name] = viewModel;
			}
			viewModel.model = model;
		}

		for (var oldName in deletedEnvironmentNames)
		{
			_environmentViewModelMap.remove(oldName);
		}
	}

	Future<Map<String, EnvironmentViewModel>> getEnvironments() async
	{
		if (_environmentViewModelMap == null)
			await _loadEnvironments();

		return _environmentViewModelMap;
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
