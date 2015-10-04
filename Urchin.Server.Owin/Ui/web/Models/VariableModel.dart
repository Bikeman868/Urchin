import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../Models/ModelBase.dart';

class VariableModel extends ModelBase
{
	VariableModel(Map json)
	{
		Reload(json);
	}

	void Reload(Map json)
	{
		startLoading(json);
		finishedLoading();
	}

	String get name => json['name'];
	set name(String value) { setProperty('name', value); }
  
	String get value => json['value'];
	set value(String value) { setProperty('value', value); }
}