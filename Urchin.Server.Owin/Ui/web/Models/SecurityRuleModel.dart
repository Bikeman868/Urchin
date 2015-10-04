import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../Models/ModelBase.dart';

class SecurityRuleModel extends ModelBase
{
	SecurityRuleModel(Map json)
	{
		Reload(json);
	}

	void Reload(Map json)
	{
		startLoading(json);
		finishedLoading();
	}

	String get startIp => json['startIp'];
	set startIp(String value) { setProperty('startIp', value); }
  
	String get endIp => json['endIp'];
	set endIp(String value) { setProperty('endIp', value); }
}