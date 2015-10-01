import 'dart:html';
import 'dart:convert';
import 'dart:async';

import 'VersionData.dart';
import 'Dto.dart';
import '../Server.dart';
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
	Map<String, EnvironmentDto> _environments;
	List<VersionDto> _versions;

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

	Future<Map<String, EnvironmentDto>> getEnvironments() async
	{
		if (_environments == null)
		{
			_environments = await Server.getEnvironments();
		}
		return _environments;
	}

	Future<List<VersionDto>> getVersions() async
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
			for (var versionDto in versions)
			{
				if (versionDto.version == version)
				{
					result = new VersionData(versionDto);
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
