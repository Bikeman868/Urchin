import 'dart:html';
import 'dart:convert';
import 'dart:async';

import 'ViewModels/DataViewModel.dart';
import 'ViewModels/EnvironmentViewModel.dart';

import 'Events/AppEvents.dart';

import 'Views/Environment/EnvironmentListView.dart';
import 'Views/Environment/EnvironmentView.dart';

Element _leftDiv;
Element _centreDiv;
Element _rightDiv;
Element _userDiv;
Element _toolBarDiv;

DataViewModel _dataViewModel;

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
	_dataViewModel = new DataViewModel();
	_displayEnvironmentList(_leftDiv);
	_displayVersionList(_centreDiv);
}

/*************************************************************************/

void _attachEvents()
{
	AppEvents.tabChanged.listen(_tabChanged);
	AppEvents.environmentSelected.listen(_environmentSelected);
}

void _tabChanged(TabChangedEvent e)
{
	if (e.tabName == 'Rules') _displayRuleList(_leftDiv);
	else if (e.tabName == 'Environments') _displayEnvironmentList(_leftDiv);
	else if (e.tabName == 'Versions') _displayVersionList(_leftDiv);
}

void _environmentSelected(EnvironmentSelectedEvent e)
{
	_displayEnvironment(e.environment, _centreDiv);
}

/*************************************************************************/

EnvironmentListView _environmentListView;

void _displayEnvironmentList(Element panel)
{
	if (_environmentListView == null)
		_environmentListView = new EnvironmentListView(_dataViewModel.environmentList);

	_environmentListView.displayIn(panel);
}

EnvironmentView _environmentView;

void _displayEnvironment(EnvironmentViewModel environment, Element panel)
{
	if (_environmentView == null)
		_environmentView = new EnvironmentView(environment);
	else
		_environmentView.viewModel = environment;

	_environmentView.displayIn(panel);
}

/*************************************************************************/

void _displayRuleList(Element panel)
{
	panel.children.clear();
}

/*************************************************************************/

void _displayVersionList(Element panel)
{
	panel.children.clear();
}
