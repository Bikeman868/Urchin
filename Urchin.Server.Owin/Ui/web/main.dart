import 'dart:html';
import 'dart:convert';
import 'dart:async';

import 'Data.dart';
import 'RuleListComponent.dart';
import 'ToolBarComponent.dart';
import 'RuleDetailComponent.dart';

Data data;

main() async
{ 
  data = new Data();
  await data.loadAll();
  setupUI();
}

void setupUI()
{
  var toolBarDiv = querySelector('#toolBarDiv');

  var leftDiv = querySelector('#leftDiv');
  var centreDiv = querySelector('#centreDiv');
  var rightDiv = querySelector('#rightDiv');

  var toolBar = new ToolBarComponent(data);
  toolBar.displayIn(toolBarDiv);
  
  var ruleList = new RuleListComponent(data);
  ruleList.displayIn(leftDiv);

  var ruleDetailComponent = new RuleDetailComponent(data);
  ruleDetailComponent.displayIn(centreDiv);
}

