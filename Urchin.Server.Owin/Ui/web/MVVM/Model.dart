part of mvvm;

class Model
{
	Map _json;
	Map _modelLists;
	Map _models;

	Model(Map json)
	{
		load(json);
	}

	void set json(Map value)
	{
		_json = value;
		_modelLists = new Map();
		_models = new Map();
	}

	Map get json
	{
		_models.forEach(
			(String name, Model model) 
			{
				if (model == null)
					_json.remove(name);
				else
					_json[name] = model.json;
			});

		_modelLists.forEach(
			(String name, List models)
			{
				List<Map> jsonList = new List<Map>();
				if (models != null)
				{
					for (Model model in models)
					{
						jsonList.add(model.json);
					}
				}
				if (jsonList.length == 0)
					_json.remove(name);
				else
					_json[name] = jsonList;
			});

		return _json;
	}

	load(Map json)
	{
		if (json == null)
			this.json = new Map();
		else
			this.json = json;
	}

	setProperty(String name, value)
	{
		_json[name] = value;
	}

	dynamic getProperty(String name)
	{
		return _json[name];
	}

	void setModel(String name, Model model)
	{
		_models[name] = model;
	}

	void setList(String name, List value)
	{
		_modelLists[name] = value;
	}

	dynamic getModel(String name, ModelFactory modelFactory)
	{
		if (_models.containsKey(name))
			return _models[name];

		Map map = _json[name];
		var model = modelFactory(map);

		_models[name] = model;
		return model;
	}

	List getList(String name, ModelFactory modelFactory)
	{
		if (_modelLists.containsKey(name))
			return _modelLists[name];

		List list = new List();

		List jsonList = _json[name];
		if (jsonList != null)
		{
			for (Map item in jsonList)
			{
				list.add(modelFactory(item));
			}
		}

		_modelLists[name] = list;
		return list;
	}
}
