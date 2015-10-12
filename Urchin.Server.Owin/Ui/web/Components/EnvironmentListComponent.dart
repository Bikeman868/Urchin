import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../DataLayer/Data.dart';
import '../ViewModels/EnvironmentViewModel.dart';
import '../Views/EnvironmentListElementView.dart';
import '../Events/AppEvents.dart';

class EnvironmentListComponent
{
	Data _data;

	EnvironmentListComponent(this._data)
	{
	}
  
	void displayIn(containerDiv) async
	{
		var heading = new SpanElement()
			..classes.add('panelTitle')
			..text = 'Environments';
		containerDiv.children.add(heading);

		Map<String, EnvironmentViewModel> environments = await _data.getEnvironments();
		if (environments != null)
		{
			var list = new UListElement();
			list.classes.add("selectionList");
			for (EnvironmentViewModel environment in environments.values)
			{
				new EnvironmentListElementView(environment)
					..environmentSelected.listen(_environmentSelected)
					..addTo(list);
			}
			containerDiv.children.add(list);
		}
	}

	void _environmentSelected(EnvironmentSelectedEvent e)
	{
		AppEvents.environmentSelected.raise(e);
	}
}
