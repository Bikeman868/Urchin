import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundList.dart';

import '../../Events/AppEvents.dart';

import '../../Models/VersionModel.dart';

import '../../Events/AppEvents.dart';

import '../../ViewModels/VersionViewModel.dart';
import '../../ViewModels/VersionListViewModel.dart';

import '../../Views/Versions/VersionListElementView.dart';

class VersionListView extends View
{
	BoundList<VersionModel, VersionViewModel, VersionListElementView> _versionsBinding;

	VersionListView([VersionListViewModel viewModel])
	{
		_heading = addHeading(3, 'Edit Versions');

		_versionsBinding = new BoundList<VersionModel, VersionViewModel, VersionListElementView>(
			(vm) => new VersionListElementView(vm), 
			addList(),
			allowAdd: false,
			selectionMethod: (vm) => AppEvents.versionSelected.raise(new VersionSelectedEvent(vm)));

		var buttonBar = addContainer(className: 'button-bar');
		addButton("Save", _saveClicked, parent: buttonBar);
		// addButton("Discard", _discardClicked, parent: buttonBar);
		addButton("Get Draft", _draftClicked, parent: buttonBar);

		this.viewModel = viewModel;
	}

	Element _heading;
	void set Title (String value)
	{
		if (_heading != null)
			_heading.innerHtml = value;
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

	void _draftClicked(MouseEvent e) async
	{
		VersionViewModel versionViewModel = await viewModel.getDraftVersion();
		AppEvents.versionSelected.raise(new VersionSelectedEvent(versionViewModel));
	}

	VersionListViewModel _viewModel;
	VersionListViewModel get viewModel => _viewModel;

	void set viewModel(VersionListViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_versionsBinding.binding = null;
		}
		else
		{
			_versionsBinding.binding = value.versions;
		}
	}  
}
