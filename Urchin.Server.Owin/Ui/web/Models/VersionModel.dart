import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../Models/ModelBase.dart';

class VersionModel extends ModelBase
{
	VersionModel(Map json)
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
  
	int get version => json['version'];
	set version(int value) { setProperty('version', value); }
}
