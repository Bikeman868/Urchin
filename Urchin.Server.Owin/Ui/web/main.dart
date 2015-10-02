import 'dart:html';
import 'dart:convert';
import 'dart:async';

import 'Models/Data.dart';
import 'Models/EnvironmentDto.dart';
import 'Events/AppEvents.dart';

import 'Components/RuleListComponent.dart';
import 'Components/ToolBarComponent.dart';
import 'Components/RuleDetailComponent.dart';
import 'Components/EnvironmentListComponent.dart';
import 'Components/EnvironmentDetailComponent.dart';
import 'Components/TestQueryComponent.dart';
import 'Components/LogonComponent.dart';
import 'Components/HelpComponent.dart';
import 'Components/VersionListComponent.dart';
import 'Components/VersionDetailComponent.dart';
import 'Components/UpdateComponent.dart';

Data data;

RuleListComponent _ruleListComponent;
RuleDetailComponent _ruleDetailComponent;
EnvironmentListComponent _environmentListComponent;
EnvironmentDetailComponent _environmentDetailComponent;
TestQueryComponent _testQueryComponent;
LogonComponent _logonComponent;
ToolBarComponent _toolBarComponent;
HelpComponent _helpComponent;
VersionListComponent _versionListComponent;
VersionDetailComponent _versionDetailComponent;
UpdateComponent _updateComponent;

Element _leftDiv;
Element _centreDiv;
Element _rightDiv;
Element _userDiv;
Element _toolBarDiv;
Element _updateDiv;

main() async
{ 
	data = new Data();
	_setupUI();
}

void _setupUI()
{
	_leftDiv = querySelector('#leftDiv');
	_centreDiv = querySelector('#centreDiv');
	_rightDiv = querySelector('#rightDiv');
	_userDiv = querySelector('#userDiv');
	_toolBarDiv = querySelector('#toolBarDiv');
	_updateDiv = querySelector('#updateDiv');

	_ruleListComponent = new RuleListComponent(data);
	_ruleDetailComponent = new RuleDetailComponent(data);
	_environmentListComponent = new EnvironmentListComponent(data);
	_environmentDetailComponent = new EnvironmentDetailComponent(data);
	_testQueryComponent = new TestQueryComponent();
	_logonComponent = new LogonComponent(data);
	_toolBarComponent = new ToolBarComponent();
	_helpComponent = new HelpComponent();
	_versionListComponent = new VersionListComponent(data);
	_versionDetailComponent = new VersionDetailComponent(data);
	_updateComponent = new UpdateComponent(data);

	_logonComponent.displayIn(_userDiv);
	_toolBarComponent.displayIn(_toolBarDiv);
	_helpComponent.displayIn(_rightDiv);
	_updateComponent.displayIn(_updateDiv);

	_setupRulesTab();

	AppEvents.tabChanged.listen(_tabChanged);
}

void _tabChanged(TabChangedEvent e)
{
	if (e.tabName == 'Rules') _setupRulesTab();
	if (e.tabName == 'Environments') _setupEnvironmentsTab();
	if (e.tabName == 'Test Query') _setupTestTab();
	if (e.tabName == 'Versions') _setupVersionsTab();
}

void _clearUI()
{
	_leftDiv.children.clear(); 
	_centreDiv.children.clear(); 
}

void _setupRulesTab()
{
	_clearUI(); 

	_ruleListComponent.displayIn(_leftDiv);
	_ruleDetailComponent.displayIn(_centreDiv);
}

void _setupEnvironmentsTab()
{
	_clearUI(); 

	_environmentListComponent.displayIn(_leftDiv);
	_environmentDetailComponent.displayIn(_centreDiv);
}

void _setupTestTab()
{
	_clearUI(); 

	_testQueryComponent.displayIn(_centreDiv);
}

void _setupVersionsTab()
{
	_clearUI(); 

	_versionListComponent.displayIn(_leftDiv);
	_versionDetailComponent.displayIn(_centreDiv);
	_ruleDetailComponent.displayIn(_centreDiv);
}

