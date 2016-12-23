import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundLabel.dart';
import '../../MVVM/BoundList.dart';
import '../../MVVM/BoundRepeater.dart';

import '../../Events/AppEvents.dart';

import '../../Models/EnvironmentModel.dart';
import '../../Models/RuleModel.dart';

import '../../ViewModels/EnvironmentViewModel.dart';
import '../../ViewModels/VersionViewModel.dart';
import '../../ViewModels/RuleViewModel.dart';

import '../../Views/Environment/EnvironmentListElementView.dart';
import '../../Views/Rules/RuleListElementView.dart';

class VersionEditView extends View
{
	BoundLabel<int> _versionBinding1;
	BoundLabel<int> _versionBinding2;
	BoundLabel<int> _versionBinding3;
	BoundLabel<String> _nameBinding;
	BoundList<EnvironmentModel, EnvironmentViewModel, EnvironmentListElementView> _environmentsBinding;
	BoundList<RuleModel, RuleViewModel, RuleListElementView> _rulesBinding;

	VersionEditView([VersionViewModel viewModel])
	{
		_versionBinding1 = new BoundLabel<int>(
			addHeading(2, 'Version Details'), 
			formatMethod: (s) => 'Version ' + s);

		_nameBinding = new BoundLabel<String>(addDiv());

		_versionBinding2 = new BoundLabel<int>(
			addHeading(3, 'Environments'), 
			formatMethod: (s) => 'Environments Using Version ' + s + ' Rules');

		_environmentsBinding = new BoundList<EnvironmentModel, EnvironmentViewModel, EnvironmentListElementView>(
			(vm) => new EnvironmentListElementView(vm), 
			addContainer(), 
			allowAdd: false, allowRemove: false,
			selectionMethod: (vm) => AppEvents.environmentSelected.raise(new EnvironmentSelectedEvent(vm)));

		_versionBinding3 = new BoundLabel<int>(
			addHeading(3, 'Rules'), 
			formatMethod: (s) => 'Version ' + s + ' Rules');

		_rulesBinding = new BoundList<RuleModel, RuleViewModel, RuleListElementView>(
			(vm) => new RuleListElementView(vm), 
			addContainer(), 
			allowAdd: false, allowRemove: false,
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
			_environmentsBinding.binding = null;
		}
		else
		{
			_versionBinding1.binding = value.version;
			_versionBinding2.binding = value.version;
			_versionBinding3.binding = value.version;
			_nameBinding.binding = value.name;
			_rulesBinding.binding = value.rules;
			_environmentsBinding.binding = value.environments;
		}
	}
}
