import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundList.dart';

import '../../Models/EnvironmentModel.dart';

import '../../Events/AppEvents.dart';

import '../../ViewModels/EnvironmentViewModel.dart';
import '../../ViewModels/EnvironmentListViewModel.dart';

import '../../Views/Environment/EnvironmentNameView.dart';

class EnvironmentListView extends View
{
	BoundList<EnvironmentModel, EnvironmentViewModel, EnvironmentNameView> _environmentsBinding;

	EnvironmentListView([EnvironmentListViewModel viewModel])
	{
		addHeading(3, 'Edit Environments');
		addBlockText('Choose an environment to edit. You can also create new environments and delete environments here. The Save button will save all changes to all environments', className: 'help-note');

		_environmentsBinding = new BoundList<EnvironmentModel, EnvironmentViewModel, EnvironmentNameView>(
			(vm) => new EnvironmentNameView(vm), 
			addList(),
			selectionMethod: (vm) => AppEvents.environmentSelected.raise(new EnvironmentSelectedEvent(vm)));

		var buttonBar = addContainer(className: 'button-bar');
		addButton("Save", _saveClicked, parent: buttonBar);
		addButton("Discard", _discardClicked, parent: buttonBar);

		this.viewModel = viewModel;
	}

	void _saveClicked(MouseEvent e)
	{
		if (viewModel != null)
			viewModel.save();
	}

	void _discardClicked(MouseEvent e)
	{
		if (viewModel != null)
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