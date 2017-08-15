import 'dart:html';

import '../../MVVM/Mvvm.dart';

import '../../Models/ApplicationModel.dart';

import '../../Events/AppEvents.dart';

import '../../ViewModels/ApplicationViewModel.dart';
import '../../ViewModels/ApplicationListViewModel.dart';

import '../../Views/Application/ApplicationNameView.dart';

class ApplicationListView extends View
{
	BoundList<ApplicationModel, ApplicationViewModel, ApplicationNameView> _applicationsBinding;

	ApplicationListView([ApplicationListViewModel viewModel])
	{
		addHeading(3, 'Edit Applications');

		addBlockText('Choose an application to edit.' + 
			'<br>You can also create new applications and delete applications here.' +
			'<br>The Save button will save all changes to all applications'
			, className: 'help-note');

		_applicationsBinding = new BoundList<ApplicationModel, ApplicationViewModel, ApplicationNameView>(
			(vm) => new ApplicationNameView(vm), 
			addList(),
			selectionMethod: (vm) => AppEvents.applicationSelected.raise(new ApplicationSelectedEvent(vm)));

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

	ApplicationListViewModel _viewModel;
	ApplicationListViewModel get viewModel => _viewModel;

	void set viewModel(ApplicationListViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_applicationsBinding.binding = null;
		}
		else
		{
			_applicationsBinding.binding = value.applications;
		}
	}
}