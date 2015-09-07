import 'dart:async';
import 'Dto.dart';

class RuleSelectedEvent
{
	String ruleName;
	RuleSelectedEvent(this.ruleName);
}

class EnvironmentSelectedEvent
{
	String environmentName;
	EnvironmentSelectedEvent(this.environmentName);
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
	UserChangedEvent(this.isLoggedOn. {this.userName});
}

class ApplicationEvents
{
	static StreamController<RuleSelectedEvent> _ruleSelectedController = new StreamController.broadcast();
	static Stream<RuleSelectedEvent> get onRuleSelected => _ruleSelectedController.stream;
	static ruleSelected(String name)
	{
		_ruleSelectedController.add(new RuleSelectedEvent(name));
	}

	static StreamController<EnvironmentSelectedEvent> _environmentSelectedController = new StreamController.broadcast();
	static Stream<EnvironmentSelectedEvent> get onEnvironmentSelected => _environmentSelectedController.stream;
	static environmentSelected(String name)
	{
		_environmentSelectedController.add(new EnvironmentSelectedEvent(name));
	}

	static StreamController<TabChangedEvent> _tabChangedController = new StreamController.broadcast();
	static Stream<TabChangedEvent> get onTabChanged => _tabChangedController.stream;
	static tabChanged(String name)
	{
		_tabChangedController.add(new TabChangedEvent(name));
	}

	static StreamController<UserChangedEvent> _userChangedController = new StreamController.broadcast();
	static Stream<UserChangedEvent> get onUserChanged => _userChangedController.stream;
	static userChanged(String userName)
	{
		var isLoggedOn = userName.length > 0;
		_userChangedController.add(new UserChangedEvent(isLoggedOn, userName));
	}
}
