import 'dart:html';
import 'dart:convert';
import 'dart:async';

import 'Dto.dart';
import 'Data.dart';
import 'ApplicationEvents.dart';

class RuleListComponent
{
	Data _data;
	RuleListComponent(this._data);
  
	void displayIn(containerDiv)
	{
		containerDiv.children.clear();

		var heading = new SpanElement();
		heading.classes.add('panelTitle');
		heading.text = 'Rules';
		containerDiv.children.add(heading);

		Map<String, RuleDto> rules = _data.rules;
		if (rules != null)
		{
			var list = new UListElement();
			list.classes.add("selectionList");
			for (RuleDto rule in rules.values)
			{
				var element = new LIElement();
				element.text = rule.name;
				element.classes.add('ruleName');
				element.classes.add('selectionItem');
				element.onClick.listen(ruleClicked);
				list.children.add(element);
			}
			containerDiv.children.add(list);
		}
	}

	void ruleClicked(MouseEvent e)
	{
		LIElement target = e.target;
		ApplicationEvents.RuleSelected(target.text);
	}
}
