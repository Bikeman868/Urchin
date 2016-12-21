import 'dart:html';
import 'dart:convert';
import 'dart:async';

import 'ViewModels/DataViewModel.dart';
import 'ViewModels/EnvironmentViewModel.dart';

import 'Events/AppEvents.dart';

import 'Views/Environment/EnvironmentListView.dart';
import 'Views/Environment/EnvironmentEditView.dart';
import 'Views/Environment/EnvironmentDisplayView.dart';
import 'Views/Navigation/ToolBarView.dart';

Element _leftDiv;
Element _centreDiv;
Element _rightDiv;
Element _userDiv;
Element _toolBarDiv;

DataViewModel _dataViewModel;
ToolBarView _toolBarView;

main() async
{ 
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
	_toolBarView = new ToolBarView();
	_toolBarView.displayIn(_toolBarDiv);

	_dataViewModel = new DataViewModel();
	_displayEnvironmentList(_leftDiv);
}

/*************************************************************************/

void _attachEvents()
{
	AppEvents.tabChanged.listen(_tabChanged);
	AppEvents.environmentSelected.listen(_environmentSelected);
}

void _tabChanged(TabChangedEvent e)
{
	_centreDiv.children.clear();

	if (e.tabName == 'Rules') _displayRuleList(_leftDiv);
	else if (e.tabName == 'Environments') _displayEnvironmentList(_leftDiv);
	else if (e.tabName == 'Versions') _displayVersionList(_leftDiv);
}

String _currentView;

void _environmentSelected(EnvironmentSelectedEvent e)
{
	if (_currentView == 'Environments')
		_displayEnvironmentEdit(e.environment, _centreDiv);
	else 
		_displayEnvironmentDisplay(e.environment, _rightDiv);
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

void _displayRuleList(Element panel)
{
	_currentView = 'Rules';

	panel.children.clear();
}

/*************************************************************************/

void _displayVersionList(Element panel)
{
	_currentView = 'Versions';

	// panel.children.clear();
}
