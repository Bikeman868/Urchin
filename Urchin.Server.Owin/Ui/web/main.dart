import 'dart:html';
import 'dart:convert';
import 'dart:async';

import 'Data.dart';
import 'RuleListComponent.dart';
import 'ToolBarComponent.dart';

Data data;

main() async
{ 
  data = new Data();
  await data.loadAll();
  SetupUI();
}

void SetupUI()
{
  var toolBarDiv = querySelector('#toolBarDiv');
  var centreDiv = querySelector('#centreDiv');
  var leftDiv = querySelector('#leftDiv');

  var toolBar = new ToolBarComponent(data);
  toolBar.displayIn(toolBarDiv);
  
  var ruleList = new RuleListComponent(data);
  ruleList.displayIn(leftDiv);
}

