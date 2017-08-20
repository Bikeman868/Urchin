import 'dart:html';
import '../../MVVM/Mvvm.dart';
import '../../Events/AppEvents.dart';
import '../../Models/DatacenterRuleModel.dart';
import '../../ViewModels/DatacenterViewModel.dart';
import '../../ViewModels/DatacenterRuleViewModel.dart';
import '../../ViewModels/DatacenterRuleListViewModel.dart';
import '../../Views/DatacenterRule/DatacenterRuleNameView.dart';

class DatacenterEditView extends View
{
	BoundTextInput<String> _nameBinding;
	BoundLabel<String> _titleBinding1;
	BoundLabel<String> _titleBinding2;
	BoundList<DatacenterRuleModel, DatacenterRuleViewModel, DatacenterRuleNameView> _rulesBinding;
	CheckboxInputElement _allRulesCheckBox;

	DatacenterRuleListViewModel _datacenterRules;

	DatacenterEditView(
		this._datacenterRules,
		[DatacenterViewModel viewModel])
	{
		_titleBinding1 = new BoundLabel<String>(
			addHeading(2, 'Datacenter Details'), 
			formatMethod: (s) => 'Edit ' + s + ' Datacenter');

		addBlockText('A datacenter is a physical location where several servers are hosted.' +
			'<br>Defining datacenters in Urchin allows you to create Urchin rules that will set certain' +
			'<br>configuration values for all software running in the datacenter. For example the' +
			'<br>location of resources like data stores and services may be different for each data center.'
			, className: 'help-note');

		var form = addForm();
		_nameBinding = new BoundTextInput<String>(addLabeledEdit(form, 'Datacenter name'));

		addHR();

		_titleBinding2 = new BoundLabel<String>(
			addHeading(2, 'Datacenter Rules'), 
			formatMethod: (s) => 'Rules for ' + s + ' datacenter');

		addBlockText('These rules will be used to determine if the software is running in this' +
			'<br>datacenter. The software can also include the datacenter as a query string parameter' +
			'<br>when it calls Urchin to bypass these rules.', 
		className: 'help-note');

		addBlockText('Note that rules are evaluated in the order of least specific to most specific' +
			'<br>and the last rule that matches (the most specific rule) will be used to determine the' +
			'<br>datacenter. These rules are initially listed in the order they will be evaluated.', 
		className: 'help-note');

		_allRulesCheckBox = addLabeledCheckbox(null, 'Show all rules');
		_allRulesCheckBox.onChange.listen(_allRulesCheckBoxChanged);

		_rulesBinding = new BoundList<DatacenterRuleModel, DatacenterRuleViewModel, DatacenterRuleNameView>(
			(vm) => new DatacenterRuleNameView(vm), 
			addContainer(),
			allowAdd: false,
			viewModelFilter: (vm) => _allRulesCheckBox.checked || (_viewModel != null && (vm.datacenter.getProperty() == _viewModel.name.getProperty())),
			selectionMethod: (vm) { AppEvents.datacenterRuleSelected.raise(new DatacenterRuleSelectedEvent(vm)); } );
		_rulesBinding.binding = _datacenterRules.datacenterRules;

		var buttonBar = addContainer(className: 'button-bar');
		addButton("New Rule", _newRuleClicked, parent: buttonBar);
		addButton("Save", _saveRulesClicked, parent: buttonBar);
		addButton("Discard", _discardRulesClicked, parent: buttonBar);

		this.viewModel = viewModel;
	}

	DatacenterViewModel _viewModel;
	DatacenterViewModel get viewModel => _viewModel;

	void set viewModel(DatacenterViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_nameBinding.binding = null;
			_titleBinding1.binding = null;
			_titleBinding2.binding = null;
		}
		else
		{
			_nameBinding.binding = value.name;
			_titleBinding1.binding = value.name;
			_titleBinding2.binding = value.name;
		}

		_rulesBinding.refresh();
	}

	void _allRulesCheckBoxChanged(Event e)
	{
		_rulesBinding.refresh();
	}

	void _newRuleClicked(MouseEvent e)
	{
		if (viewModel != null)
		{
			var model = new DatacenterRuleModel(null);
			model.datacenterName = viewModel.name.getProperty();
			var vm = _datacenterRules.datacenterRules.addModel(model);

			_rulesBinding.refresh();

			AppEvents.datacenterRuleSelected.raise(new DatacenterRuleSelectedEvent(vm));
		}
	}

	void _saveRulesClicked(MouseEvent e)
	{
			_datacenterRules.save();
	}

	void _discardRulesClicked(MouseEvent e)
	{
			_datacenterRules.reload();
	}
}