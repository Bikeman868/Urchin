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
	BoundList<EnvironmentModel, EnvironmentViewModel, EnvironmentListElementView> _environmentsBinding;

	EnvironmentListView([EnvironmentListViewModel viewModel])
	{
		addHeading(3, 'Environments');

		_environmentsBinding = new BoundList<EnvironmentModel, EnvironmentViewModel, EnvironmentListElementView>(
			(vm) => new EnvironmentListElementView(vm), 
			addList(),
			selectionMethod: (vm) => AppEvents.environmentSelected.raise(new EnvironmentSelectedEvent(vm)));

		var buttonBar = addContainer(className: 'button-bar');
		addButton("Save", _saveClicked, parent: buttonBar);
		addButton("Discard", _discardClicked, parent: buttonBar);

		this.viewModel = viewModel;
	}

	void _saveClicked(MouseEvent e)
	{
		viewModel.save();
	}

	void _discardClicked(MouseEvent e)
	{
		viewModel.reload();
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
}