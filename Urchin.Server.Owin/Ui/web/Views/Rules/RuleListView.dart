import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundList.dart';
import '../../MVVM/BoundLabel.dart';
import '../../MVVM/StringBinding.dart';

import '../../Events/AppEvents.dart';

import '../../Models/RuleModel.dart';

import '../../Events/AppEvents.dart';

import '../../ViewModels/VersionViewModel.dart';
import '../../ViewModels/RuleViewModel.dart';

import '../../Views/Rules/RuleNameView.dart';

class RuleListView extends View
{
	BoundLabel<int> _versionLabel;
	BoundLabel<String> _nameLabel;
	BoundList<RuleModel, RuleViewModel, RuleNameView> _rulesBinding;

	InputElement instanceFilter;
	InputElement applicationFilter;
	InputElement machineFilter;
	InputElement environmentFilter;
	CheckboxInputElement inclusiveCheckBox;

	String _instanceFilter = '';
	String _applicationFilter = '';
	String _machineFilter = '';
	String _environmentFilter = '';
	bool _inclusiveFilter;

	RuleListView([VersionViewModel viewModel])
	{
		_versionLabel = new BoundLabel<int>(
			addHeading(3, 'Version Details'), 
			formatMethod: (s) => 'Version ' + s + ' Rules');

		_nameLabel = new BoundLabel<String>(addDiv());

		addHR();
		addHeading(3, 'Show only these rules');
		addBlockText('You can use this filter to find the rules that you want to modify', className: 'help-note');

		var filterForm = addForm(className: 'rule-filter');
		instanceFilter = addLabeledEdit(filterForm, 'Instance');
		applicationFilter = addLabeledEdit(filterForm, 'Application');
		machineFilter = addLabeledEdit(filterForm, 'Machine');
		environmentFilter = addLabeledEdit(filterForm, 'Environment');
		inclusiveCheckBox = addLabeledCheckbox(filterForm, 'Inclusive');

		var filterButtonBar = addContainer(className: 'button-bar');
		addButton("Apply Filter", _applyFilterClicked, parent: filterButtonBar);
		addButton("Clear Filter", _clearFilterClicked, parent: filterButtonBar);

		addHR();
		addHeading(3, 'Filtered list of rules');
		addBlockText('Choose which rule you want to modify. You can also create and delete rules. The save button will save all changes to this version of the rules.', className: 'help-note');

		_rulesBinding = new BoundList<RuleModel, RuleViewModel, RuleNameView>(
			(vm) => new RuleNameView(vm), 
			addList(),
			allowAdd: false,
			selectionMethod: (vm) => AppEvents.ruleSelected.raise(new RuleSelectedEvent(vm)),
			viewModelFilter: _ruleFilter);

		var buttonBar = addContainer(className: 'button-bar');
		addButton("New Rule", _newClicked, parent: buttonBar);
		addButton("Save", _saveClicked, parent: buttonBar);
		addButton("Discard", _discardClicked, parent: buttonBar);

		this.viewModel = viewModel;
	}

	bool _ruleFilter(RuleViewModel rule)
	{
		if (!matchesFilter(_instanceFilter, rule.instance)) return false;
		if (!matchesFilter(_applicationFilter, rule.application)) return false;
		if (!matchesFilter(_machineFilter, rule.machine)) return false;
		if (!matchesFilter(_environmentFilter, rule.environment)) return false;

		return true;
	}

	bool matchesFilter(String s, StringBinding b)
	{
		if (s == null || s.length == 0) 
			return true;

		if (b == null) 
			return _inclusiveFilter;

		String v = b.getProperty();
		if (v == null || v.length == 0) 
			return _inclusiveFilter;

		return s.toUpperCase() == v.toUpperCase();
	}

	void _applyFilterClicked(MouseEvent e)
	{
		_instanceFilter = instanceFilter.value;
		_applicationFilter = applicationFilter.value;
		_machineFilter = machineFilter.value;
		_environmentFilter = environmentFilter.value;
		_inclusiveFilter = inclusiveCheckBox.checked;

		_rulesBinding.refresh();
	}

	void _clearFilterClicked(MouseEvent e)
	{
		instanceFilter.value = '';
		applicationFilter.value = '';
		machineFilter.value = '';
		environmentFilter.value = '';

		_applyFilterClicked(e);
	}

	void _newClicked(MouseEvent e)
	{
		if (viewModel != null)
		{
			String name = '';
			if (_environmentFilter.length > 0)
				name = name + 'Env ' + _environmentFilter + ' ';
			if (_machineFilter.length > 0)
				name = name + 'Svr ' + _machineFilter + ' ';
			if (_applicationFilter.length > 0)
				name = name + 'App ' + _applicationFilter + ' ';
			if (_instanceFilter.length > 0)
				name = name + 'Ins ' + _instanceFilter + ' ';

			if (name.length == 0) 
				name = 'Root';
			else
				name = name.substring(0, name.length - 1);

			var ruleJson = new Map();
			ruleJson['name'] = name;
			ruleJson['instance'] = _instanceFilter;
			ruleJson['application'] = _applicationFilter;
			ruleJson['machine'] = _machineFilter;
			ruleJson['environment'] = _environmentFilter;

			viewModel.rules.addModel(new RuleModel(ruleJson));
		}
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
			_versionLabel.binding = null;
			_nameLabel.binding = null;
			_rulesBinding.binding = null;
		}
		else
		{
			_versionLabel.binding = value.version;
			_nameLabel.binding = value.name;
			_rulesBinding.binding = value.rules;
		}
	}  
}
