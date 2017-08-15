import 'dart:html';
import 'dart:convert';
import 'dart:async';

import 'MVVM/Mvvm.dart';

import 'ViewModels/DataViewModel.dart';
import 'ViewModels/EnvironmentViewModel.dart';
import 'ViewModels/VersionViewModel.dart';
import 'ViewModels/RuleViewModel.dart';
import 'ViewModels/ApplicationViewModel.dart';
import 'ViewModels/DatacenterViewModel.dart';
import 'ViewModels/DatacenterRuleViewModel.dart';

import 'Events/AppEvents.dart';

import 'Views/Environment/EnvironmentListView.dart';
import 'Views/Environment/EnvironmentEditView.dart';
import 'Views/Environment/EnvironmentDisplayView.dart';

import 'Views/Versions/VersionListView.dart';
import 'Views/Versions/VersionEditView.dart';
import 'Views/Versions/VersionDisplayView.dart';

import 'Views/Navigation/ToolBarView.dart';
import 'Views/Navigation/LogonView.dart';

import 'Views/Rules/RuleDisplayView.dart';
import 'Views/Rules/RuleEditView.dart';
import 'Views/Rules/RuleListView.dart';
import 'Views/Rules/RuleConfigView.dart';

import 'Views/Application/ApplicationListView.dart';
import 'Views/Application/ApplicationEditView.dart';
import 'Views/Application/ApplicationDisplayView.dart';

Element _leftDiv;
Element _centreDiv;
Element _rightDiv;
Element _userDiv;
Element _toolBarDiv;

DataViewModel _dataViewModel;
ToolBarView _toolBarView;
LogonView _logonView;

main()
{ 
	HtmlBuilder.Initialize();

	_bindHtml();
	_initialView();
	_attachEvents();
}

/*************************************************************************/

void _bindHtml()
{
	_leftDiv = querySelector('#leftDiv');
	_centreDiv = querySelector('#centreDiv');
	_rightDiv = querySelector('#rightDiv');
	_userDiv = querySelector('#userDiv');
	_toolBarDiv = querySelector('#toolBarDiv');
}

/*************************************************************************/

void _initialView()
{
	_dataViewModel = new DataViewModel();

	_toolBarView = new ToolBarView();
	_toolBarView.displayIn(_toolBarDiv);

	_logonView = new LogonView(_dataViewModel.user);
	_logonView.displayIn(_userDiv);

	_tabChanged(new TabChangedEvent('Rules'));
}

/*************************************************************************/

void _attachEvents()
{
	AppEvents.tabChanged.listen(_tabChanged);
	AppEvents.ruleEdit.listen(_ruleEdit);

	AppEvents.environmentSelected.listen(_environmentSelected);
	AppEvents.versionSelected.listen(_versionSelected);
	AppEvents.ruleSelected.listen(_ruleSelected);
	AppEvents.applicationSelected.listen(_applicationSelected);
	AppEvents.datacenterSelected.listen(_datacenterSelected);
	AppEvents.datacenterRuleSelected.listen(_datacenterRuleSelected);
}

void _tabChanged(TabChangedEvent e)
{
	_centreDiv.children.clear();

	if (e.tabName == 'Rules')
	{
		_displayVersionList(
			_leftDiv, 'Rule Versions', 
			'Choose which version of the rules you want to edit, or create a draft version which is not used by any environment.');

		_currentView = 'Rules';
	}
	else if (e.tabName == 'Environments') 
	{
		_displayEnvironmentList(_leftDiv);
	}
	else if (e.tabName == 'Versions') 
	{
		_displayVersionList(
			_leftDiv, 'Edit Versions', 
			'Choose a version to edit. You can also delete old versions here, or create a new draft version that can be modified safely.<br>The save button will save changes to all versions.');
	}
	else if (e.tabName == 'Applications') 
	{
		_displayApplicationList(_leftDiv);
	}
}

String _currentView;

void _environmentSelected(EnvironmentSelectedEvent e)
{
	if (_currentView == 'Environments')
		_displayEnvironmentEdit(e.environment, _centreDiv);
	else 
		_displayEnvironmentDisplay(e.environment, _rightDiv);
}

void _versionSelected(VersionSelectedEvent e)
{
	if (_currentView == 'Versions')
		_displayVersionEdit(e.version, _centreDiv);
	else
	{
		if (_currentView == 'Rules')
			_displayRuleList(e.version, _leftDiv);
		_displayVersionDisplay(e.version, _rightDiv);
	}
}

void _ruleSelected(RuleSelectedEvent e)
{
	if (_currentView == 'Rules')
	{
		_displayRuleEdit(e.rule, _centreDiv);
		_displayRuleConfig(e.rule, _rightDiv);
	}
	else
		_displayRuleDisplay(e.rule, _rightDiv);
}

void _applicationSelected(ApplicationSelectedEvent e)
{
	if (_currentView == 'Applications')
		_displayApplicationEdit(e.application, _centreDiv);
	else 
		_displayApplicationDisplay(e.application, _rightDiv);
}

void _datacenterSelected(DatacenterSelectedEvent e)
{
}

void _datacenterRuleSelected(DatacenterRuleSelectedEvent e)
{
}

void _ruleEdit(RuleEditEvent e)
{
	_displayRuleEdit(e.rule, _centreDiv);
}

/*************************************************************************/

void clearPanel(Element panel)
{
	panel.children.clear();
}

/*************************************************************************/

EnvironmentListView _environmentListView;

void _displayEnvironmentList(Element panel)
{
	_currentView = 'Environments';

	if (_environmentListView == null)
		_environmentListView = new EnvironmentListView(_dataViewModel.environmentList);

	_environmentListView.displayIn(panel);
}

EnvironmentEditView _environmentEditView;

void _displayEnvironmentEdit(EnvironmentViewModel environment, Element panel)
{
	if (_environmentEditView == null)
		_environmentEditView = new EnvironmentEditView(environment);
	else
		_environmentEditView.viewModel = environment;

	_environmentEditView.displayIn(panel);
}

EnvironmentDisplayView _environmentDisplayView;

void _displayEnvironmentDisplay(EnvironmentViewModel environment, Element panel)
{
	if (_environmentDisplayView == null)
		_environmentDisplayView = new EnvironmentDisplayView(environment);
	else
		_environmentDisplayView.viewModel = environment;

	_environmentDisplayView.displayIn(panel);
}

/*************************************************************************/

RuleListView _ruleListView;

void _displayRuleList(VersionViewModel version, Element panel)
{
	_dataViewModel.versionList.ensureRules(version)
		.then((Null n)
		{
			if (_ruleListView == null)
				_ruleListView = new RuleListView(version);
			else
				_ruleListView.viewModel = version;

			_ruleListView.displayIn(panel);
		});
}

RuleEditView _ruleEditView;

void _displayRuleEdit(RuleViewModel rule, Element panel)
{
	if (_ruleEditView == null)
		_ruleEditView = new RuleEditView(rule);
	else
		_ruleEditView.viewModel = rule;

	_ruleEditView.displayIn(panel);
}

RuleDisplayView _ruleDisplayView;

void _displayRuleDisplay(RuleViewModel rule, Element panel)
{
	if (_ruleDisplayView == null)
		_ruleDisplayView = new RuleDisplayView(rule);
	else
		_ruleDisplayView.viewModel = rule;

	_ruleDisplayView.displayIn(panel);
}

RuleConfigView _ruleConfigView;

void _displayRuleConfig(RuleViewModel rule, Element panel)
{
	if (_ruleConfigView == null)
		_ruleConfigView = new RuleConfigView(rule);
	else
		_ruleConfigView.viewModel = rule;

	_ruleConfigView.displayIn(panel);
}

/*************************************************************************/

VersionListView _versionListView;

void _displayVersionList(Element panel, String title, String description)
{
	_currentView = 'Versions';

	if (_versionListView == null)
		_versionListView = new VersionListView(_dataViewModel.versionList);

	_versionListView.Title = title;
	_versionListView.Description = description;

	_versionListView.displayIn(panel);
}

VersionEditView _versionEditView;

void _displayVersionEdit(VersionViewModel version, Element panel)
{
	_dataViewModel.versionList.ensureRules(version)
		.then((Null n)
			{
				if (_versionEditView == null)
					_versionEditView = new VersionEditView(version);
				else
					_versionEditView.viewModel = version;

				_versionEditView.environmentListBinding = _dataViewModel.environmentList.environments;
				_versionEditView.displayIn(panel);
			});
}

VersionDisplayView _versionDisplayView;

void _displayVersionDisplay(VersionViewModel version, Element panel)
{
	_dataViewModel.versionList.ensureRules(version)
		.then((Null n)
			{
				if (_versionDisplayView == null)
					_versionDisplayView = new VersionDisplayView(version);
				else
					_versionDisplayView.viewModel = version;

				_versionDisplayView.environmentListBinding = _dataViewModel.environmentList.environments;
				_versionDisplayView.displayIn(panel);
			});
}

/*************************************************************************/

ApplicationListView _applicationListView;

void _displayApplicationList(Element panel)
{
	_currentView = 'Applications';

	if (_applicationListView == null)
		_applicationListView = new ApplicationListView(_dataViewModel.applicationList);

	_applicationListView.displayIn(panel);
}

ApplicationEditView _applicationEditView;

void _displayApplicationEdit(ApplicationViewModel application, Element panel)
{
	if (_applicationEditView == null)
		_applicationEditView = new ApplicationEditView(application);
	else
		_applicationEditView.viewModel = application;

	_applicationEditView.displayIn(panel);
}

ApplicationDisplayView _applicationDisplayView;

void _displayApplicationDisplay(ApplicationViewModel application, Element panel)
{
	if (_applicationDisplayView == null)
		_applicationDisplayView = new ApplicationDisplayView(application);
	else
		_applicationDisplayView.viewModel = application;

	_applicationDisplayView.displayIn(panel);
}

/*************************************************************************/

