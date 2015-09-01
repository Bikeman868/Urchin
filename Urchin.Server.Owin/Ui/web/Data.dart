import 'dart:html';
import 'dart:convert';
import 'dart:async';

import 'Dto.dart';
import 'Server.dart';

class Data
{
	List<String> ruleNames;
	Map<String, RuleDto> rules;

	Future loadAll() async
	{
		await loadRuleNames();
		await loadRules();
	}

	loadRuleNames() async
	{
		String content = await Server.getRules();
		List<Map> rules = JSON.decode(content);

		var ruleNames = new List<String>();
		for (Map rule in rules)
		{
			ruleNames.add(rule['name']);
		}
		this.ruleNames = ruleNames;
	}

	loadRules() async 
	{
		var rules = new Map<String, RuleDto>();
		for (String ruleName in this.ruleNames)
		{
			String content = await Server.getRule(ruleName);
			Map rule = JSON.decode(content);
			rules[ruleName] = new RuleDto(rule);
		}
		this.rules = rules;
	}
}
