import 'dart:html';
import 'dart:convert';
import 'dart:async';

import 'Dto.dart';
import '../Server.dart';
import '../Events/AppEvents.dart';
import '../Events/SubscriptionEvent.dart';

class VersionDataEvent
{
	VersionData versionData;
	VersionDataEvent(this.versionData);
}

class VersionData
{
	VersionDto version;

	List<String> _ruleNames;
	RuleVersionDto _rules;

	SubscriptionEvent<VersionDataEvent> refreshedEvent = new SubscriptionEvent<VersionDataEvent>();
	SubscriptionEvent<VersionDataEvent> modifiedEvent = new SubscriptionEvent<VersionDataEvent>();
	SubscriptionEvent<VersionDataEvent> deletedEvent = new SubscriptionEvent<VersionDataEvent>();

	VersionData(this.version);

	reload()
	{
		_ruleNames = null;
		_rules = null;

		refreshedEvent.raise(new VersionDataEvent(this));
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