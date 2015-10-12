import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../DataBinding/Types.dart';

class Model
{
	Map json;

	Model(Map json)
	{
		load(json);
	}

	load(Map json)
	{
		if (json == null)
			this.json = new Map();
		else
			this.json = json;
	}

	Map save()
	{
		return json;
	}

	setProperty(String name, value)
	{
		json[name] = value;
	}

	dynamic getProperty(String name)
	{
		return json[name];
	}

	void setModel(String name, Model model)
	{
		setProperty(name, model.json);
	}

	dynamic getModel(String name, ModelFactory modelFactory)
	{
		Map map = getProperty(name);
		return modelFactory(map);
	}

	void setList(String name, List value)
	{
		List jsonList = new List<Map>();
		for (Model model in value)
		{
			jsonList.add(model.json);
		}
		setProperty(name, jsonList);
	}

	List getList(String name, ModelFactory modelFactory)
	{
		List list = new List();
		List jsonList = getProperty(name);
		if (jsonList != null)
		{
			for (Map item in jsonList)
			{
				list.add(modelFactory(item));
			}
		}
		return list;
	}
}
