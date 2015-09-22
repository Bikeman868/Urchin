import 'dart:async';
import 'Dto.dart';
import 'Data.dart';

class RuleSelectedEvent
{
	int version;
	String ruleName;
	RuleSelectedEvent(this.version, this.ruleName);
}

class EnvironmentSelectedEvent
{
	String environmentName;
	EnvironmentSelectedEvent(this.environmentName);
}

class VersionSelectedEvent
{
	int version;
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

class DataRefreshedEvent
{
	Data data;
	DataRefreshedEvent(this.data);
}

class VersionDataRefreshedEvent
{
	VersionData versionData;
	VersionDataRefreshedEvent(this.versionData);
}

class AppEvents
{
	static Event<RuleSelectedEvent> ruleSelected = new Event<RuleSelectedEvent>();
	static Event<EnvironmentSelectedEvent> environmentSelected = new Event<EnvironmentSelectedEvent>();
	static Event<VersionSelectedEvent> versionSelected = new Event<VersionSelectedEvent>();
	static Event<TabChangedEvent> tabChanged = new Event<TabChangedEvent>();
	static Event<UserChangedEvent> userChanged = new Event<UserChangedEvent>();
	static Event<DataRefreshedEvent> dataRefreshed = new Event<DataRefreshedEvent>();
	static Event<VersionDataRefreshedEvent> versionDataRefreshed = new Event<VersionDataRefreshedEvent>();
}

class Event<E>
{
	StreamController<E> _controller = new StreamController.broadcast();
  
	raise(E e)
	{
		_controller.add(e);
	}

	StreamSubscription<E> listen(void handler(E e)) 
	{
		return _controller.stream.listen(handler);
	}
}
