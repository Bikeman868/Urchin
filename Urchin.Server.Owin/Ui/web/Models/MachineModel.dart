import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../Models/ModelBase.dart';

class MachineModel extends ModelBase
{
	String _name;

	MachineModel(String name)
	{
		Reload(name);
	}

	void Reload(String name)
	{
		startLoading(null);
		_name = name;
		finishedLoading();
	}

	String get name => _name;
	set name(String value) 
	{ 
		_name = value;
		propertyModified();
	}
}

