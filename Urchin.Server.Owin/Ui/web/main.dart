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

Data data;

main() async
{ 
  data = new Data();
  await data.loadAll();
  _setupUI();
}

void _setupUI()
{
	var toolBarDiv = querySelector('#toolBarDiv');

	var toolBar = new ToolBarComponent();
	toolBar.displayIn(toolBarDiv);

	_setupRulesTab();

	ApplicationEvents.onTabChanged.listen(_tabChanged);
}

void _tabChanged(TabChangedEvent e)
{
	if (e.tabName == 'Rules') _setupRulesTab();
	if (e.tabName == 'Environments') _setupEnvironmentsTab();
}

void _setupRulesTab()
{
  var leftDiv = querySelector('#leftDiv');
  var centreDiv = querySelector('#centreDiv');
  var rightDiv = querySelector('#rightDiv');

  leftDiv.children.clear(); 
  centreDiv.children.clear(); 
  rightDiv.children.clear(); 

  var ruleList = new RuleListComponent(data);
  ruleList.displayIn(leftDiv);

  var ruleDetailComponent = new RuleDetailComponent(data);
  ruleDetailComponent.displayIn(centreDiv);
}

void _setupEnvironmentsTab()
{
  var leftDiv = querySelector('#leftDiv');
  var centreDiv = querySelector('#centreDiv');
  var rightDiv = querySelector('#rightDiv');

  leftDiv.children.clear(); 
  centreDiv.children.clear(); 
  rightDiv.children.clear(); 

  var environmentList = new EnvironmentListComponent(data);
  environmentList.displayIn(leftDiv);

  var environmentDetailComponent = new EnvironmentDetailComponent(data);
  environmentDetailComponent.displayIn(centreDiv);
}


