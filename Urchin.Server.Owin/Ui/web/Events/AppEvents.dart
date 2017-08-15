import 'dart:async';

import '../MVVM/Mvvm.dart';

import '../ViewModels/EnvironmentViewModel.dart';
import '../ViewModels/VersionViewModel.dart';
import '../ViewModels/RuleViewModel.dart';

class RuleSelectedEvent
{
	RuleViewModel rule;
	RuleSelectedEvent(this.rule);
}

class RuleEditEvent
{
	RuleViewModel rule;
	RuleEditEvent(this.rule);
}

class EnvironmentSelectedEvent
{
	EnvironmentViewModel environment;
	EnvironmentSelectedEvent(this.environment);
}

class VersionSelectedEvent
{
	VersionViewModel version;
	VersionSelectedEvent(this.version);
}

class TabChangedEvent
{
	String tabName;
	TabChangedEvent(this.tabName);
}

class UserChangedEvent
{
	String userName;
	bool isLoggedOn;
	String ipAddress;
	UserChangedEvent(this.isLoggedOn, this.userName, this.ipAddress);
}

class AppEvents
{
	static SubscriptionEvent<RuleSelectedEvent> ruleSelected = new SubscriptionEvent<RuleSelectedEvent>();
	static SubscriptionEvent<RuleEditEvent> ruleEdit = new SubscriptionEvent<RuleEditEvent>();
	static SubscriptionEvent<EnvironmentSelectedEvent> environmentSelected = new SubscriptionEvent<EnvironmentSelectedEvent>();
	static SubscriptionEvent<VersionSelectedEvent> versionSelected = new SubscriptionEvent<VersionSelectedEvent>();
	static SubscriptionEvent<TabChangedEvent> tabChanged = new SubscriptionEvent<TabChangedEvent>();
	static SubscriptionEvent<UserChangedEvent> userChanged = new SubscriptionEvent<UserChangedEvent>();
}
