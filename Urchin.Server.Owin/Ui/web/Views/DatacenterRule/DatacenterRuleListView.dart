import 'dart:html';

import '../../MVVM/Mvvm.dart';

import '../../Models/DatacenterRuleModel.dart';

import '../../Events/AppEvents.dart';

import '../../ViewModels/DatacenterRuleViewModel.dart';
import '../../ViewModels/DatacenterRuleListViewModel.dart';

import '../../Views/DatacenterRule/DatacenterRuleNameView.dart';

class DatacenterRuleListView extends View
{
	BoundList<DatacenterRuleModel, DatacenterRuleViewModel, DatacenterRuleNameView> _datacenterRulesBinding;

	DatacenterRuleListView([DatacenterRuleListViewModel viewModel])
	{
		addHeading(3, 'Edit Datacenter Rules');

		addBlockText('Choose an datacenter rule to edit.' + 
			'<br>You can also create new datacenterRules and delete datacenter rules here.' +
			'<br>The Save button will save all changes to all datacenter rules'
			, className: 'help-note');

		_datacenterRulesBinding = new BoundList<DatacenterRuleModel, DatacenterRuleViewModel, DatacenterRuleNameView>(
			(vm) => new DatacenterRuleNameView(vm), 
			addList(),
			selectionMethod: (vm) => AppEvents.datacenterRuleSelected.raise(new DatacenterRuleSelectedEvent(vm)));

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

	DatacenterRuleListViewModel _viewModel;
	DatacenterRuleListViewModel get viewModel => _viewModel;

	void set viewModel(DatacenterRuleListViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_datacenterRulesBinding.binding = null;
		}
		else
		{
			_datacenterRulesBinding.binding = value.datacenterRules;
		}
	}
}