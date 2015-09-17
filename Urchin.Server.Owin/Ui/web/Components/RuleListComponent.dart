import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../Dto.dart';
import '../Data.dart';
import '../ApplicationEvents.dart';
import '../Html/HtmlBuilder.dart';

class RuleListComponent
{
	Data _data;
	HtmlBuilder _builder;
	Element _ruleList;
	StreamSubscription<DataRefreshedEvent> _onDataRefreshedSubscription;
	int version;

	RuleListComponent(this._data)
	{
		_builder = new HtmlBuilder();
		_builder.addBlockText('Rules', className: 'panelTitle');
		_ruleList = _builder.addList(className: 'selectionList');

		_onDataRefreshedSubscription = ApplicationEvents.onDataRefreshed.listen(_dataRefreshed);
		_dataChanged(_data);
	}

	void dispose()
	{
		_onDataRefreshedSubscription.cancel();
		_onDataRefreshedSubscription = null;
	}
  
	void displayIn(containerDiv)
	{
		_builder.displayIn(containerDiv);
	}

	void _dataRefreshed(DataRefreshedEvent e)
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
		ApplicationEvents.ruleSelected(version, target.text);
	}
}
