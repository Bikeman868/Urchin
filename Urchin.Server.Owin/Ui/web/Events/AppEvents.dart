import '../MVVM/Mvvm.dart';

import '../ViewModels/EnvironmentViewModel.dart';
import '../ViewModels/VersionViewModel.dart';
import '../ViewModels/RuleViewModel.dart';
import '../ViewModels/ApplicationViewModel.dart';
import '../ViewModels/DatacenterViewModel.dart';
import '../ViewModels/DatacenterRuleViewModel.dart';

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

class ApplicationSelectedEvent
{
	ApplicationViewModel application;
	ApplicationSelectedEvent(this.application);
}

class DatacenterSelectedEvent
{
	DatacenterViewModel datacenter;
	DatacenterSelectedEvent(this.datacenter);
}

class DatacenterRuleSelectedEvent
{
	DatacenterRuleViewModel datacenterRule;
	DatacenterRuleSelectedEvent(this.datacenterRule);
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
	static SubscriptionEvent<EnvironmentSelectedEvent> environmentSelected = new SubscriptionEvent<EnvironmentSelectedEvent>();
	static SubscriptionEvent<VersionSelectedEvent> versionSelected = new SubscriptionEvent<VersionSelectedEvent>();
	static SubscriptionEvent<ApplicationSelectedEvent> applicationSelected = new SubscriptionEvent<ApplicationSelectedEvent>();
	static SubscriptionEvent<DatacenterSelectedEvent> datacenterSelected = new SubscriptionEvent<DatacenterSelectedEvent>();
	static SubscriptionEvent<DatacenterRuleSelectedEvent> datacenterRuleSelected = new SubscriptionEvent<DatacenterRuleSelectedEvent>();

	static SubscriptionEvent<RuleEditEvent> ruleEdit = new SubscriptionEvent<RuleEditEvent>();
	static SubscriptionEvent<TabChangedEvent> tabChanged = new SubscriptionEvent<TabChangedEvent>();
	static SubscriptionEvent<UserChangedEvent> userChanged = new SubscriptionEvent<UserChangedEvent>();
}
