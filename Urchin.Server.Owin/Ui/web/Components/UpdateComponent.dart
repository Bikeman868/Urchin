import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../Dto.dart';
import '../Data.dart';
import '../Server.dart';
import '../AppEvents.dart';
import '../Html/HtmlBuilder.dart';

class UpdateComponent
{
	Data _data;

	Element _container;
	HtmlBuilder _builder;

	Element _refreshButton;
	Element _saveButton;
	Element _changesSpan;
  
	UpdateComponent(Data data)
	{
		_data = data;
		_buildUI();
	}

	void _buildUI()
	{
		_builder = new HtmlBuilder();
		
		_refreshButton = _builder.addButton('Refresh', _refreshClick, className: 'toolBarButton');
		_saveButton = _builder.addButton('Save', _saveClick, className: 'toolBarButton');
		_changesSpan = _builder.addBlockText('No changes');
	}

	void dispose()
	{
	}
  
	void displayIn(Element container) async
	{
		_container = container;
		_builder.addTo(_container);
	}

	void _refreshClick(MouseEvent e)
	{
		_data.reload();
	}

	void _saveClick(MouseEvent e)
	{
	}  
}
