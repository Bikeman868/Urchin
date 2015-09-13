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

		for(var v in _versionedData)
			v.reload();

		ApplicationEvents.dataRefreshed(this);
	}

	Future<Map<String, EnvironmentDto>> get environments async
	{
		if (_environments == null)
		{
			_environments = await Server.getEnvironments();
		}
		return _environments;
	}

	Future<List<VersionDto>> get versions async
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
	Map<String, RuleDto> _rules;

	VersionData(this.version);

	reload()
	{
		_ruleNames = null;
		_rules = null;
	}

	Future<List<String>> get ruleNames async
	{
		if (_ruleNames == null)
		{
			_ruleNames = await Server.getRuleNames(version);
		}
		return _ruleNames;
	}

	Future<Map<String, RuleDto>> get rules async
	{
		if (_rules == null)
		{
			_rules = await Server.getRules(version);
		}
		return _rules;
	}
}