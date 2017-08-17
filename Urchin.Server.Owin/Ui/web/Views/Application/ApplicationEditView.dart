import '../../MVVM/Mvvm.dart';

import '../../Events/AppEvents.dart';

import '../../Models/RuleModel.dart';

import '../../ViewModels/ApplicationViewModel.dart';
import '../../ViewModels/RuleViewModel.dart';

import '../../Views/Rules/RuleNameView.dart';

class ApplicationEditView extends View
{
	BoundTextInput<String> _nameBinding;
	BoundLabel<String> _titleBinding;
	BoundList<RuleModel, RuleViewModel, RuleNameView> _rulesBinding;

	ApplicationEditView([ApplicationViewModel viewModel])
	{
		_titleBinding = new BoundLabel<String>(
			addHeading(2, 'Application Details'), 
			formatMethod: (s) => 'Edit ' + s + ' Application');

		addBlockText('Unique application names must be hard coded into each application.' +
			'<br>When an application requests its configuration from Urchin it must include' +
			'<br>its unique application name in the query string of the URL.',
			className: 'help-note');

		var form = addForm();
		_nameBinding = new BoundTextInput<String>(addLabeledEdit(form, 'Application name'));

		addHR();
		addHeading(3, 'Rules');

		addBlockText(
			'These are the rules that apply only to this application', 
			className: 'help-note');

		_rulesBinding = new BoundList<RuleModel, RuleViewModel, RuleNameView>(
			(vm) => new RuleNameView(vm), 
			addList(),
			allowAdd: false,
			selectionMethod: (vm) => AppEvents.ruleSelected.raise(new RuleSelectedEvent(vm)),
			viewModelFilter: _ruleFilter);

		this.viewModel = viewModel;
	}

	bool _ruleFilter(RuleViewModel rule)
	{
		if (_viewModel == null) return false;
		return rule.application.getProperty().toUpperCase() == _viewModel.name.getProperty().toUpperCase();
	}

	ApplicationViewModel _viewModel;
	ApplicationViewModel get viewModel => _viewModel;

	void set viewModel(ApplicationViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_nameBinding.binding = null;
			_titleBinding.binding = null;
			_rulesBinding.binding = null;			
		}
		else
		{
			_nameBinding.binding = value.name;
			_titleBinding.binding = value.name;
			//_rulesBinding.binding = value.rules;
		}
	}

}