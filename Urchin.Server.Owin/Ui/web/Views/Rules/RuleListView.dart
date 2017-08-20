import 'dart:html';
import '../../MVVM/Mvvm.dart';
import '../../Events/AppEvents.dart';
import '../../Models/RuleModel.dart';
import '../../Models/ApplicationModel.dart';
import '../../Models/EnvironmentModel.dart';
import '../../Models/DatacenterModel.dart';
import '../../ViewModels/VersionViewModel.dart';
import '../../ViewModels/RuleViewModel.dart';
import '../../ViewModels/ApplicationViewModel.dart';
import '../../ViewModels/ApplicationListViewModel.dart';
import '../../ViewModels/EnvironmentViewModel.dart';
import '../../ViewModels/EnvironmentListViewModel.dart';
import '../../ViewModels/DatacenterListViewModel.dart';
import '../../ViewModels/DatacenterViewModel.dart';
import '../../Views/Rules/RuleNameView.dart';
import '../../Views/Application/ApplicationNameView.dart';
import '../../Views/Environment/EnvironmentNameView.dart';
import '../../Views/Datacenter/DatacenterNameView.dart';

class RuleListView extends View
{
	BoundLabel<int> _versionLabel;
	BoundLabel<String> _nameLabel;
	BoundList<RuleModel, RuleViewModel, RuleNameView> _rulesBinding;
	BoundSelect<ApplicationModel, ApplicationViewModel, ApplicationNameView> _applicationsBinding;
	BoundSelect<EnvironmentModel, EnvironmentViewModel, EnvironmentNameView> _environmentsBinding;
	BoundSelect<DatacenterModel, DatacenterViewModel, DatacenterNameView> _datacentersBinding;

	InputElement instanceFilter;
	SelectElement applicationDropdown;
	InputElement machineFilter;
	SelectElement environmentDropdown;
	SelectElement datacenterDropdown;
	CheckboxInputElement inclusiveCheckBox;

	String _instanceFilter = '';
	String _applicationFilter = '';
	String _machineFilter = '';
	String _environmentFilter = '';
	String _datacenterFilter = '';
	bool _inclusiveFilter;

	RuleListView(
		ApplicationListViewModel applicationList, 
		EnvironmentListViewModel environmentList,
		DatacenterListViewModel datacenterList,
		[VersionViewModel viewModel])
	{
		_versionLabel = new BoundLabel<int>(
			addHeading(3, 'Version Details'), 
			formatMethod: (s) => 'Version ' + s + ' Rules');

		_nameLabel = new BoundLabel<String>(addDiv());

		addHR();
		addHeading(3, 'Show only these rules');
		addBlockText('You can use this filter to find the rules that you want to modify', className: 'help-note');

		var filterForm = addForm(className: 'rule-filter');
		machineFilter = addLabeledEdit(filterForm, 'Machine');
		instanceFilter = addLabeledEdit(filterForm, 'Instance');
		applicationDropdown = addLabeledDropdownList(filterForm, 'Application');
		environmentDropdown = addLabeledDropdownList(filterForm, 'Environment');
		datacenterDropdown = addLabeledDropdownList(filterForm, 'Datacenter');
		inclusiveCheckBox = addLabeledCheckbox(filterForm, 'Inclusive');

		_applicationsBinding = new BoundSelect<ApplicationModel, ApplicationViewModel, ApplicationNameView>(
			(vm) => new ApplicationNameView(vm),
			applicationDropdown,
			(vm) { _applicationFilter = vm == null ? null : vm.name.getProperty(); },
			staticListItems: [new View()]
		);
		_applicationsBinding.binding = applicationList.applications;

		_environmentsBinding = new BoundSelect<EnvironmentModel, EnvironmentViewModel, EnvironmentNameView>(
			(vm) => new EnvironmentNameView(vm),
			environmentDropdown,
			(vm) { _environmentFilter = vm == null ? null : vm.name.getProperty(); },
			staticListItems: [new View()]
		);
		_environmentsBinding.binding = environmentList.environments;

		_datacentersBinding = new BoundSelect<DatacenterModel, DatacenterViewModel, DatacenterNameView>(
			(vm) => new DatacenterNameView(vm),
			datacenterDropdown,
			(vm) { _datacenterFilter = vm == null ? null : vm.name.getProperty(); },
			staticListItems: [new View()]
		);
		_datacentersBinding.binding = datacenterList.datacenters;

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
		if (!matchesFilter(_datacenterFilter, rule.datacenter)) return false;

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
		_machineFilter = machineFilter.value;
		_inclusiveFilter = inclusiveCheckBox.checked;

		_rulesBinding.refresh();
	}

	void _clearFilterClicked(MouseEvent e)
	{
		instanceFilter.value = '';
		machineFilter.value = '';

		applicationDropdown.selectedIndex = 0;
		environmentDropdown.selectedIndex = 0;
		datacenterDropdown.selectedIndex = 0;

		_applyFilterClicked(e);
	}

	void _newClicked(MouseEvent e)
	{
		if (viewModel != null)
		{
			String name = '';
			if (_datacenterFilter.length > 0)
				name = name + _datacenterFilter + ' ';
			if (_environmentFilter.length > 0)
				name = name + _environmentFilter + ' ';
			if (_machineFilter.length > 0)
				name = name + _machineFilter + ' ';
			if (_applicationFilter.length > 0)
				name = name + 'App ' + _applicationFilter + ' ';
			if (_instanceFilter.length > 0)
				name = name + _instanceFilter + ' ';

			if (name.length == 0) 
				name = 'New rule';
			else
				name = name.substring(0, name.length - 1);

			var ruleJson = new Map();
			ruleJson['name'] = name;
			ruleJson['instance'] = _instanceFilter;
			ruleJson['application'] = _applicationFilter;
			ruleJson['machine'] = _machineFilter;
			ruleJson['environment'] = _environmentFilter;
			ruleJson['datacenter'] = _datacenterFilter;

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
