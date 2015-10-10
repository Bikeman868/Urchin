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
	Map<int, VersionData> _versionedData;
	Map<String, EnvironmentViewModel> _environments;
	List<VersionModel> _versions;

	Data()
	{
		_versionedData = new Map<int, VersionData>();
		AppEvents.userChanged.listen(_userChanged);
	}

	reload() async
	{
		await _loadEnvironments();
		_versions = null;

		for(var version in _versionedData.values)
			version.reload();

		AppEvents.dataLoadedEvent.raise(new DataEvent(this));
	}

	save()
	{
		for(var version in _versionedData.values)
			version.save();

		_saveEnvironments();

		AppEvents.dataSavedEvent.raise(new DataEvent(this));
	}

	_saveEnvironments()
	{
	}

	_loadEnvironments() async
	{
		var environmentModels = await Server.getEnvironments();
		List<String> deletedEnvironments = new List<String>();

		if (_environments == null)
		{
			_environments = new Map<String, EnvironmentViewModel>();
		}
		else
		{
			for (var name in _environments.keys)
			{
				if (environmentModels[name] == null)
					deletedEnvironments.add(name);
			}
		}

		for (var name in environmentModels.keys)
		{
			EnvironmentViewModel viewModel = _environments[name];
			if (viewModel == null)
			{
				if (deletedEnvironments.length > 0)
				{
					var oldName = deletedEnvironments[0];
					deletedEnvironments.removeAt(0);
					viewModel = _environments[oldName];
					_environments.remove(oldName);
				}
				else
				{
					viewModel = new EnvironmentViewModel();
				}
				_environments[name] = viewModel;
			}
			viewModel.model = environmentModels[name];
		}

		for (var oldName in deletedEnvironments)
		{
			_environments.remove(oldName);
		}
	}

	Future<Map<String, EnvironmentViewModel>> getEnvironments() async
	{
		if (_environments == null)
			await _loadEnvironments();

		return _environments;
	}

	Future<List<VersionModel>> getVersions() async
	{
		if (_versions == null)
		{
			_versions = await Server.getVersions();
		}
		return _versions;
	}

	Future<VersionData> getVersion(int version) async
	{
		VersionData result = _versionedData[version];
		if (result == null)
		{
			var versions = await getVersions();
			for (var versionModel in versions)
			{
				if (versionModel.version == version)
				{
					result = new VersionData(versionModel);
					_versionedData[version] = result;
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
