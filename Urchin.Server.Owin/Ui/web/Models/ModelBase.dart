import 'dart:html';
import 'dart:convert';
import 'dart:async';

class ModelBase
{
	Map json;
	bool isModified;
	bool _loading;

	void startLoading(Map json)
	{
		_loading = true;
		this.json = json;
		isModified = false;
	}

	void finishedLoading()
	{
		_loading = false;
	}

	void propertyModified()
	{
		if (!_loading)
			isModified = true;
	}

	void setProperty(String name, dynamic value)
	{
		json[name] = value;
		propertyModified();
	}
}
