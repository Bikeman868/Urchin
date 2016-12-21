import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundList.dart';

import '../../Models/EnvironmentModel.dart';

import '../../Events/AppEvents.dart';

import '../../ViewModels/EnvironmentViewModel.dart';
import '../../ViewModels/EnvironmentListViewModel.dart';
import '../../ViewModels/DataViewModel.dart';

import '../../Views/Environment/EnvironmentListElementView.dart';

class EnvironmentListView extends View
{
	Element environments;

	BoundList<EnvironmentModel, EnvironmentViewModel, EnvironmentListElementView> _environmentsBinding;

	EnvironmentListView([EnvironmentListViewModel viewModel])
	{
		addHeading(3, 'Environments');
		environments = addList();

		_environmentsBinding = new BoundList<EnvironmentModel, EnvironmentViewModel, EnvironmentListElementView>(
			(vm) => new EnvironmentListElementView(vm), 
			environments,
			selectionMethod: (vm) => AppEvents.environmentSelected.raise(new EnvironmentSelectedEvent(vm)));

		this.viewModel = viewModel;
	}

	EnvironmentListViewModel _viewModel;
	EnvironmentListViewModel get viewModel => _viewModel;

	void set viewModel(EnvironmentListViewModel value)
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