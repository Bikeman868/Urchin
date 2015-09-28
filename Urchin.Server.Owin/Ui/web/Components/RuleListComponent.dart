import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../Model/Dto.dart';
import '../Model/Data.dart';
import '../Model/VersionData.dart';
import '../Events/AppEvents.dart';
import '../Html/HtmlBuilder.dart';

class RuleListComponent
{
	Data _data;
	HtmlBuilder _builder;
	Element _ruleList;
	StreamSubscription<DataEvent> _dataRefreshedSubscription;
	int version;

	RuleListComponent(this._data)
	{
		_builder = new HtmlBuilder();
		_builder.addBlockText('Rules', className: 'panelTitle');
		_ruleList = _builder.addList(className: 'selectionList');

		_dataRefreshedSubscription = _data.refreshedEvent.listen(_dataRefreshed);
		_dataChanged(_data);
	}

	void dispose()
	{
		_dataRefreshedSubscription.cancel();
		_dataRefreshedSubscription = null;
	}
  
	void displayIn(containerDiv)
	{
		_builder.displayIn(containerDiv);
	}

	void _dataRefreshed(DataEvent e)
	{
		_dataChanged(e.data);
	}

	void _dataChanged(Data data) async
	{
		version = 1;
		VersionData versionData = await data.getVersion(version);
		List<String> ruleNames = await versionData.getRuleNames();

		_data = data;
		_ruleList.children.clear();

		if (ruleNames != null)
		{
			for (String ruleName in ruleNames)
			{
				var element = new LIElement();
				element.text = ruleName;
				element.classes.add('ruleName');
				element.classes.add('selectionItem');
				element.onClick.listen(_ruleClicked);
				_ruleList.children.add(element);
			}
		}
	}

	void _ruleClicked(MouseEvent e)
	{
		Element target = e.target;
		AppEvents.ruleSelected.raise(new RuleSelectedEvent(version, target.text));
	}
}
