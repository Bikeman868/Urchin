import 'dart:html';

import '../Html/FormBuilder.dart';

import '../DataBinding/View.dart';
import '../DataBinding/BoundList.dart';

import '../Models/EnvironmentModel.dart';

import '../ViewModels/EnvironmentViewModel.dart';
import '../ViewModels/DataViewModel.dart';

import '../Views/EnvironmentListElementView.dart';

class EnvironmentListView extends View
{
	Element environments;

	BoundList<EnvironmentModel, EnvironmentViewModel, EnvironmentListElementView> _environmentsBinding;

	EnvironmentListView([DataViewModel viewModel])
	{
		environments = new UListElement()
			..classes.add('selectionList');

		_environmentsBinding = new BoundList<EnvironmentModel, EnvironmentViewModel, EnvironmentListElementView>(
			(vm) => new EnvironmentListElementView(vm), 
			environments);

		this.viewModel = viewModel;
	}

	DataViewModel _viewModel;
	DataViewModel get viewModel => _viewModel;

	void set viewModel(DataViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_environmentsBinding.binding = null;
		}
		else
		{
			_environmentsBinding.binding = value.environments;
		}
	}

	void addTo(Element container)
	{
		container.children.add(environments);
	}

	void displayIn(Element container)
	{
		container.children.clear();
		addTo(container);
	}
}