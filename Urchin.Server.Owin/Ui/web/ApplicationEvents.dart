import 'dart:async';
import 'Dto.dart';
import 'Data.dart';

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
	UserChangedEvent(this.isLoggedOn, { this.userName });
}

class DataRefreshedEvent
{
	Data data;
	DataRefreshedEvent(this.data);
}

class ApplicationEvents
{
	static StreamController<RuleSelectedEvent> _ruleSelectedController = new StreamController.broadcast();
	static Stream<RuleSelectedEvent> get onRuleSelected => _ruleSelectedController.stream;
	static ruleSelected(String name)
	{
		print('User selected the ' + name + ' rule');
		_ruleSelectedController.add(new RuleSelectedEvent(name));
	}

	static StreamController<EnvironmentSelectedEvent> _environmentSelectedController = new StreamController.broadcast();
	static Stream<EnvironmentSelectedEvent> get onEnvironmentSelected => _environmentSelectedController.stream;
	static environmentSelected(String name)
	{
		print('User selected the ' + name + ' environment');
		_environmentSelectedController.add(new EnvironmentSelectedEvent(name));
	}

	static StreamController<TabChangedEvent> _tabChangedController = new StreamController.broadcast();
	static Stream<TabChangedEvent> get onTabChanged => _tabChangedController.stream;
	static tabChanged(String name)
	{
		print('User changed to the ' + name + ' tab');
		_tabChangedController.add(new TabChangedEvent(name));
	}

	static StreamController<UserChangedEvent> _userChangedController = new StreamController.broadcast();
	static Stream<UserChangedEvent> get onUserChanged => _userChangedController.stream;
	static userChanged(String userName)
	{
		var isLoggedOn = userName != null && userName.length > 0;
		if (isLoggedOn)
		{
			print('User logged on as ' + userName);
			_userChangedController.add(new UserChangedEvent(true, userName: userName));
		}
		else
		{
			print('User logged off');
			_userChangedController.add(new UserChangedEvent(false));
		}
	}

	static StreamController<DataRefreshedEvent> _dataRefreshedController = new StreamController.broadcast();
	static Stream<DataRefreshedEvent> get onDataRefreshed => _dataRefreshedController.stream;
	static dataRefreshed(Data data)
	{
		print('All data needs to be refreshed');
		_dataRefreshedController.add(new DataRefreshedEvent(data));
	}
}
