import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../DataLayer/Data.dart';
import '../ViewModels/DataViewModel.dart';
import '../Views/EnvironmentListView.dart';
import '../Events/AppEvents.dart';

class EnvironmentListComponent
{
	EnvironmentListView _view;
	Element heading;

	EnvironmentListComponent(DataViewModel viewModel)
	{
		heading = new SpanElement()
			..classes.add('panelTitle')
			..text = 'Environments';
		_view = new EnvironmentListView(viewModel);
	}
  
	void displayIn(containerDiv) async
	{
		containerDiv.children.clear();
		containerDiv.children.add(heading);
		_view.addTo(containerDiv);
	}
}
