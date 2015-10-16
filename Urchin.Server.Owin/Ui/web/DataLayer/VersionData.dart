import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../Models/RuleVersionModel.dart';
import '../Models/VersionModel.dart';
import '../Server.dart';
import '../Events/AppEvents.dart';
import '../Events/SubscriptionEvent.dart';

class VersionData
{
	VersionModel version;

	List<String> _ruleNames;
	RuleVersionModel _rules;

	VersionData(this.version);

	reload() async
	{
		_ruleNames = null;
		_rules = null;
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

	Future<RuleVersionModel> getRules() async
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