import 'dart:html';

import '../../MVVM/Mvvm.dart';

import '../../Models/DatacenterModel.dart';

import '../../Events/AppEvents.dart';

import '../../ViewModels/DatacenterViewModel.dart';
import '../../ViewModels/DatacenterListViewModel.dart';

import '../../Views/Datacenter/DatacenterNameView.dart';

class DatacenterListView extends View
{
	BoundList<DatacenterModel, DatacenterViewModel, DatacenterNameView> _datacentersBinding;

	DatacenterListView([DatacenterListViewModel viewModel])
	{
		addHeading(3, 'Edit Datacenters');

		addBlockText('Choose an datacenter to edit.' + 
			'<br>You can also create new datacenters and delete datacenters here.' +
			'<br>The Save button will save all changes to all datacenters'
			, className: 'help-note');

		_datacentersBinding = new BoundList<DatacenterModel, DatacenterViewModel, DatacenterNameView>(
			(vm) => new DatacenterNameView(vm), 
			addList(),
			selectionMethod: (vm) => AppEvents.datacenterSelected.raise(new DatacenterSelectedEvent(vm)));

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

	DatacenterListViewModel _viewModel;
	DatacenterListViewModel get viewModel => _viewModel;

	void set viewModel(DatacenterListViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_datacentersBinding.binding = null;
		}
		else
		{
			_datacentersBinding.binding = value.datacenters;
		}
	}
}