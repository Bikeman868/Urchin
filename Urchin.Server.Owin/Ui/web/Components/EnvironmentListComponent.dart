import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../Dto.dart';
import '../Data.dart';
import '../ApplicationEvents.dart';

class EnvironmentListComponent
{
	Data _data;
	EnvironmentListComponent(this._data);
  
	void displayIn(containerDiv) async
	{
		var heading = new SpanElement();
		heading.classes.add('panelTitle');
		heading.text = 'Environments';
		containerDiv.children.add(heading);

		Map<String, EnvironmentDto> environments = await _data.getEnvironments();
		if (environments != null)
		{
			var list = new UListElement();
			list.classes.add("selectionList");
			for (EnvironmentDto environment in environments.values)
			{
				var element = new LIElement();
				element.text = environment.name;
				element.classes.add('environmentName');
				element.classes.add('selectionItem');
				element.onClick.listen(environmentClicked);
				list.children.add(element);
			}
			containerDiv.children.add(list);
		}
	}

	void environmentClicked(MouseEvent e)
	{
		LIElement target = e.target;
		ApplicationEvents.environmentSelected(target.text);
	}
}
