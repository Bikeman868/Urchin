import 'dart:async';
import 'Dto.dart';

class RuleSelectedEvent
{
	String ruleName;
	RuleSelectedEvent(this.ruleName);
}

class ApplicationEvents
{
	static StreamController<RuleSelectedEvent> _ruleSelectedController = new StreamController<RuleSelectedEvent>();
	static Stream<RuleSelectedEvent> get onRuleSelected => _ruleSelectedController.stream;
	static RuleSelected(String name)
	{
		_ruleSelectedController.add(new RuleSelectedEvent(name));
	}
}
