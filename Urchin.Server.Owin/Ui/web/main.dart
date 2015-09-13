import 'dart:html';
import 'dart:convert';
import 'dart:async';

import 'Data.dart';
import 'ApplicationEvents.dart';

import 'Components/RuleListComponent.dart';
import 'Components/ToolBarComponent.dart';
import 'Components/RuleDetailComponent.dart';
import 'Components/EnvironmentListComponent.dart';
import 'Components/EnvironmentDetailComponent.dart';
import 'Components/TestQueryComponent.dart';
import 'Components/LogonComponent.dart';

Data data;

RuleListComponent _ruleListComponent;
RuleDetailComponent _ruleDetailComponent;
EnvironmentListComponent _environmentListComponent;
EnvironmentDetailComponent _environmentDetailComponent;
TestQueryComponent _testQueryComponent;
LogonComponent _logonComponent;
ToolBarComponent _toolBarComponent;

main() async
{ 
  data = new Data();
  _setupUI();
}

void _setupUI()
{
	_ruleListComponent = new RuleListComponent(data);
	_ruleDetailComponent = new RuleDetailComponent(data);
	_environmentListComponent = new EnvironmentListComponent(data);
	_environmentDetailComponent = new EnvironmentDetailComponent(data);
	_testQueryComponent = new TestQueryComponent();
	_logonComponent = new LogonComponent(data);
	_toolBarComponent = new ToolBarComponent();

	var userDiv = querySelector('#userDiv');
	_logonComponent.displayIn(userDiv);

	var toolBarDiv = querySelector('#toolBarDiv');
	_toolBarComponent.displayIn(toolBarDiv);

	_setupRulesTab();

	ApplicationEvents.onTabChanged.listen(_tabChanged);
}

void _tabChanged(TabChangedEvent e)
{
	if (e.tabName == 'Rules') _setupRulesTab();
	if (e.tabName == 'Environments') _setupEnvironmentsTab();
	if (e.tabName == 'Test Query') _setupTestTab();
}

void _setupRulesTab()
{
  var leftDiv = querySelector('#leftDiv');
  var centreDiv = querySelector('#centreDiv');
  var rightDiv = querySelector('#rightDiv');

  leftDiv.children.clear(); 
  centreDiv.children.clear(); 
  rightDiv.children.clear(); 

  _ruleListComponent.displayIn(leftDiv);
  _ruleDetailComponent.displayIn(centreDiv);
}

void _setupEnvironmentsTab()
{
  var leftDiv = querySelector('#leftDiv');
  var centreDiv = querySelector('#centreDiv');
  var rightDiv = querySelector('#rightDiv');

  leftDiv.children.clear(); 
  centreDiv.children.clear(); 
  rightDiv.children.clear(); 

  _environmentListComponent.displayIn(leftDiv);
  _environmentDetailComponent.displayIn(centreDiv);
}

void _setupTestTab()
{
  var leftDiv = querySelector('#leftDiv');
  var centreDiv = querySelector('#centreDiv');
  var rightDiv = querySelector('#rightDiv');

  leftDiv.children.clear(); 
  centreDiv.children.clear(); 
  rightDiv.children.clear(); 

  var div1 = new DivElement();
  div1.text = 
	'Use this page to test the configuration that will be returned '
	'to each application on each machine.';
  div1.classes.add('instruction');
  leftDiv.children.add(div1);

  var div2 = new DivElement();
  div2.text = 
	'Note that this request goes '
	'back to the server, so any changes you made on your browser will not '
	'be reflected in the results until you save your changes back to the server';
  div2.classes.add('instruction');
  leftDiv.children.add(div2);

  _testQueryComponent.displayIn(centreDiv);
}

