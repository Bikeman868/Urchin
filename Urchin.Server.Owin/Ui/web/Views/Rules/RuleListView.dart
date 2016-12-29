import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundList.dart';
import '../../MVVM/BoundLabel.dart';

import '../../Events/AppEvents.dart';

import '../../Models/RuleModel.dart';

import '../../Events/AppEvents.dart';

import '../../ViewModels/VersionViewModel.dart';
import '../../ViewModels/RuleViewModel.dart';

import '../../Views/Rules/RuleNameView.dart';

class RuleListView extends View
{
	BoundLabel<int> _versionBinding;
	BoundLabel<String> _nameBinding;
	BoundList<RuleModel, RuleViewModel, RuleNameView> _rulesBinding;

	RuleListView([VersionViewModel viewModel])
	{
		_versionBinding = new BoundLabel<int>(
			addHeading(3, 'Version Details'), 
			formatMethod: (s) => 'Version ' + s);

		_nameBinding = new BoundLabel<String>(addDiv());

		addHeading(3, 'Rules');

		_rulesBinding = new BoundList<RuleModel, RuleViewModel, RuleNameView>(
			(vm) => new RuleNameView(vm), 
			addList(),
			selectionMethod: (vm) => AppEvents.ruleSelected.raise(new RuleSelectedEvent(vm)));

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

	VersionViewModel _viewModel;
	VersionViewModel get viewModel => _viewModel;

	void set viewModel(VersionViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_versionBinding.binding = null;
			_nameBinding.binding = null;
			_rulesBinding.binding = null;
		}
		else
		{
			_versionBinding.binding = value.version;
			_nameBinding.binding = value.name;
			_rulesBinding.binding = value.rules;
		}
	}  
}
