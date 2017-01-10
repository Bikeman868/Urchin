import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundLabel.dart';
import '../../MVVM/BoundList.dart';
import '../../MVVM/BoundRepeater.dart';
import '../../MVVM/ModelList.dart';
import '../../MVVM/BoundTextInput.dart';

import '../../Events/AppEvents.dart';

import '../../Models/EnvironmentModel.dart';
import '../../Models/RuleModel.dart';

import '../../ViewModels/EnvironmentViewModel.dart';
import '../../ViewModels/VersionViewModel.dart';
import '../../ViewModels/RuleViewModel.dart';

import '../../Views/Environment/EnvironmentNameView.dart';
import '../../Views/Rules/RuleNameView.dart';

class VersionEditView extends View
{
	BoundLabel<int> _versionLabel1;
	BoundLabel<int> _versionLabel2;
	BoundLabel<int> _versionLabel3;
	BoundTextInput<String> _nameInput;
	BoundRepeater<EnvironmentModel, EnvironmentViewModel, EnvironmentNameView> _environmentsList;
	BoundList<RuleModel, RuleViewModel, RuleNameView> _rulesList;

	VersionEditView([VersionViewModel viewModel])
	{
		_versionLabel1 = new BoundLabel<int>(
			addHeading(2, 'Version Details'), 
			formatMethod: (s) => 'Edit Version ' + s);

		var form = addForm();
		_nameInput = new BoundTextInput<String>(addLabeledEdit(form, 'Version name'));

		_versionLabel2 = new BoundLabel<int>(
			addHeading(3, 'Environments'), 
			formatMethod: (s) => 'Environments using version ' + s + ' rules');

		addBlockText('Editing this version of the rules could impact the environments listed below:', className: 'help-note');

		_environmentsList = new BoundRepeater<EnvironmentModel, EnvironmentViewModel, EnvironmentNameView>(
			(vm) => new EnvironmentNameView(vm), 
			addContainer(),
			viewModelFilter: (vm) => _viewModel != null && vm.version.getProperty() == _viewModel.version.getProperty());

		var buttonBar = addContainer(className: 'button-bar');
		addButton("Save", _saveClicked, parent: buttonBar);
		addButton("Discard", _discardClicked, parent: buttonBar);
		// addButton("Copy", _copyClicked, parent: buttonBar);

		addHR();

		_versionLabel3 = new BoundLabel<int>(
			addHeading(3, 'Rules'), 
			formatMethod: (s) => 'Version ' + s + ' Rules');

		addBlockText('These are the rules defined in this version', className: 'help-note');

		_rulesList = new BoundList<RuleModel, RuleViewModel, RuleNameView>(
			(vm) => new RuleNameView(vm), 
			addContainer(),
			allowAdd: false,
			selectionMethod: (vm) => AppEvents.ruleSelected.raise(new RuleSelectedEvent(vm)));

		this.viewModel = viewModel;
	}

	VersionViewModel _viewModel;
	VersionViewModel get viewModel => _viewModel;

	void set viewModel(VersionViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_versionLabel1.binding = null;
			_versionLabel2.binding = null;
			_versionLabel3.binding = null;
			_nameInput.binding = null;
			_rulesList.binding = null;
		}
		else
		{
			_versionLabel1.binding = value.version;
			_versionLabel2.binding = value.version;
			_versionLabel3.binding = value.version;
			_nameInput.binding = value.name;
			_rulesList.binding = value.rules;
		}
	}

	void set environmentListBinding(ModelList<EnvironmentModel, EnvironmentViewModel> value)
	{
		_environmentsList.binding = value;
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

	void _copyClicked(MouseEvent e)
	{
		if (viewModel != null)
			viewModel = viewModel.createDraft();
	}
}
