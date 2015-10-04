import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../Models/VersionModel.dart';
import '../Models/RuleModel.dart';

class RuleVersionModel extends VersionModel
{
	Map<String, RuleModel> rules;

	RuleVersionModel(Map json): super(json)
	{
		Reload(json);
	}

	void Reload(Map json)
	{
		startLoading(json);

		rules = new Map<String, RuleModel>();
    
		List jsonRules = json['rules'];
		if (jsonRules != null)
		{
			for (var r in jsonRules)
			{
				rules[r['name']] = new RuleModel(r);
			}
		}

		finishedLoading();
	}
}
