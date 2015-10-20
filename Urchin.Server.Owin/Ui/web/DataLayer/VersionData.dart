import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../Models/VersionModel.dart';
import '../Server.dart';
import '../Events/AppEvents.dart';
import '../Events/SubscriptionEvent.dart';

class VersionData
{
	VersionModel version;

	List<String> _ruleNames;

	VersionData(this.version);

	reload() async
	{
		_ruleNames = null;
		version = null;
	}

	Future<bool> save() async
	{
		return true;
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

	Future<VersionModel> getRules() async
	{
		if (version == null || !version.hasRules)
		{
			if (version == null || version.version < 1)
				version = await Server.getDraftRules();
			else
				version = await Server.getRules(version.version);
		}
		return version;
	}
}