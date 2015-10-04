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

class DataEvent
{
	Data data;
	DataEvent(this.data);
}

class Data
{
	Map<int, VersionData> _versionedData;
	Map<String, EnvironmentViewModel> _environments;
	List<VersionModel> _versions;

	SubscriptionEvent<DataEvent> refreshedEvent = new SubscriptionEvent<DataEvent>();
	SubscriptionEvent<DataEvent> versionAddedEvent = new SubscriptionEvent<DataEvent>();
	SubscriptionEvent<DataEvent> versionDeletedEvent = new SubscriptionEvent<DataEvent>();

	Data()
	{
		_versionedData = new Map<int, VersionData>();
		AppEvents.userChanged.listen(_userChanged);
	}

	reload()
	{
		_environments = null;
		_versions = null;

		for(var version in _versionedData.values)
			version.reload();

		refreshedEvent.raise(new DataEvent(this));
	}

	Future<Map<String, EnvironmentViewModel>> getEnvironments() async
	{
		if (_environments == null)
		{
			var environmentModels = await Server.getEnvironments();
			_environments = new Map<String, EnvironmentViewModel>();
			for (var name in environmentModels.keys)
			{
				_environments[name] = new EnvironmentViewModel(environmentModels[name]);
			}
		}
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
