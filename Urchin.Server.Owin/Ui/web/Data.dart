import 'dart:html';
import 'dart:convert';
import 'dart:async';

import 'Dto.dart';
import 'Server.dart';
import 'ApplicationEvents.dart';

class Data
{
	Map<int, VersionData> _versionedData;
	Map<String, EnvironmentDto> _environments;
	List<VersionDto> _versions;

	Data()
	{
		_versionedData = new Map<int, VersionData>();
		ApplicationEvents.onUserChanged.listen(_userChanged);
	}

	reload()
	{
		_environments = null;
		_versions = null;

		for(var version in _versionedData.values)
			version.reload();

		ApplicationEvents.dataRefreshed(this);
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

	VersionData getVersion(int version)
	{
		VersionData result = _versionedData[version];
		if (result == null)
		{
			result = new VersionData(version);
			_versionedData[version] = result;
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
	int version;

	List<String> _ruleNames;
	RuleVersionDto _rules;

	VersionData(this.version);

	reload()
	{
		_ruleNames = null;
		_rules = null;
	}

	Future<List<String>> getRuleNames() async
	{
		if (_ruleNames == null)
		{
			if (version == null || version < 1)
				_ruleNames = await Server.getDraftRuleNames();
			else
				_ruleNames = await Server.getRuleNames(version);
		}
		return _ruleNames;
	}

	Future<RuleVersionDto> getRules() async
	{
		if (_rules == null || version < 1)
		{
			if (version == null)
				_rules = await Server.getDraftRules();
			else
				_rules = await Server.getRules(version);
		}
		return _rules;
	}
}