import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../DataLayer/Data.dart';
import '../Models/EnvironmentModel.dart';
import '../Events/AppEvents.dart';

class EnvironmentListComponent
{
	Data _data;

	EnvironmentListComponent(this._data)
	{
	}
  
	void displayIn(containerDiv) async
	{
		var heading = new SpanElement();
		heading.classes.add('panelTitle');
		heading.text = 'Environments';
		containerDiv.children.add(heading);

		Map<String, EnvironmentViewModel> environments = await _data.getEnvironments();
		if (environments != null)
		{
			var list = new UListElement();
			list.classes.add("selectionList");
			for (EnvironmentViewModel environment in environments.values)
			{
				var element = new LIElement();
				element.text = environment.name.getProperty();
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
		AppEvents.environmentSelected.raise(new EnvironmentSelectedEvent(target.text));
	}
}
