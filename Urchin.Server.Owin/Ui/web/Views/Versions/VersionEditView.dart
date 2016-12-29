import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundLabel.dart';
import '../../MVVM/BoundList.dart';
import '../../MVVM/BoundRepeater.dart';
import '../../MVVM/ModelListBinding.dart';
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
	BoundLabel<int> _versionBinding1;
	BoundLabel<int> _versionBinding2;
	BoundLabel<int> _versionBinding3;
	BoundTextInput<String> _nameBinding;
	BoundRepeater<EnvironmentModel, EnvironmentViewModel, EnvironmentNameView> _environmentsBinding;
	BoundList<RuleModel, RuleViewModel, RuleNameView> _rulesBinding;

	VersionEditView([VersionViewModel viewModel])
	{
		_versionBinding1 = new BoundLabel<int>(
			addHeading(2, 'Version Details'), 
			formatMethod: (s) => 'Version ' + s);

		var form = addForm();
		_nameBinding = new BoundTextInput<String>(addLabeledEdit(form, 'Version name'));

		_versionBinding2 = new BoundLabel<int>(
			addHeading(3, 'Environments'), 
			formatMethod: (s) => 'Environments Using Version ' + s + ' Rules');

		_environmentsBinding = new BoundRepeater<EnvironmentModel, EnvironmentViewModel, EnvironmentNameView>(
			(vm) => new EnvironmentNameView(vm), 
			addContainer(),
			viewModelFilter: (vm) => _viewModel != null && vm.version.getProperty() == _viewModel.version.getProperty());

		var buttonBar = addContainer(className: 'button-bar');
		addButton("Save", _saveClicked, parent: buttonBar);
		addButton("Discard", _discardClicked, parent: buttonBar);
		// addButton("Copy", _copyClicked, parent: buttonBar);

		addHR();

		_versionBinding3 = new BoundLabel<int>(
			addHeading(3, 'Rules'), 
			formatMethod: (s) => 'Version ' + s + ' Rules');

		_rulesBinding = new BoundList<RuleModel, RuleViewModel, RuleNameView>(
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
			_versionBinding1.binding = null;
			_versionBinding2.binding = null;
			_versionBinding3.binding = null;
			_nameBinding.binding = null;
			_rulesBinding.binding = null;
		}
		else
		{
			_versionBinding1.binding = value.version;
			_versionBinding2.binding = value.version;
			_versionBinding3.binding = value.version;
			_nameBinding.binding = value.name;
			_rulesBinding.binding = value.rules;
		}
	}

	void set environmentListBinding(ModelListBinding<EnvironmentModel, EnvironmentViewModel> value)
	{
		_environmentsBinding.binding = value;
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
