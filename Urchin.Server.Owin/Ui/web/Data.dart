import 'dart:html';
import 'dart:convert';
import 'dart:async';

import 'Dto.dart';
import 'Server.dart';
import 'AppEvents.dart';

class Data
{
	Map<int, VersionData> _versionedData;
	Map<String, EnvironmentDto> _environments;
	List<VersionDto> _versions;

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

		AppEvents.dataRefreshed.raise(new DataRefreshedEvent(this));
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

class VersionData
{
	VersionDto version;

	List<String> _ruleNames;
	RuleVersionDto _rules;

	VersionData(this.version);

	reload()
	{
		_ruleNames = null;
		_rules = null;

		AppEvents.versionDataRefreshed.raise(new VersionDataRefreshedEvent(this));
	}

	Future<List<String>> getRuleNames() async
	{
		if (_ruleNames == null)
		{
			if (version == null || version.version < 1)
				_ruleNames = await Server.getDraftRuleNames();
			else
				_ruleNames = await Server.getRuleNames(version.version);
		}
		return _ruleNames;
	}

	Future<RuleVersionDto> getRules() async
	{
		if (_rules == null)
		{
			if (version == null || version.version < 1)
				_rules = await Server.getDraftRules();
			else
				_rules = await Server.getRules(version.version);
		}
		return _rules;
	}
}