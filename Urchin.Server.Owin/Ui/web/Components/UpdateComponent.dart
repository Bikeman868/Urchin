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

	Element _refreshButton;
	Element _saveButton;
	Element _changesDiv;
  
	UpdateComponent(Data data)
	{
		_data = data;
		_buildUI();
	}

	void _buildUI()
	{
		/*
		_builder = new HtmlBuilder();
		
		_refreshButton = _builder.addImage('/ui/images/download{_v_}.gif', onClick: _refreshClick, className: 'imageButton');
		_saveButton = _builder.addImage('/ui/images/upload{_v_}.gif', onClick: _saveClick, className: 'imageButton');
		_changesDiv = _builder.addBlockText('No changes');
		*/

		_refreshButton = querySelector('#downloadButton');
		_refreshButton.onClick.listen(_refreshClick);

		_saveButton = querySelector('#uploadButton');
		_saveButton.onClick.listen(_saveClick);

		_changesDiv = querySelector('#changesDiv');
		_changesDiv.innerHtml = 'No changes';
	}

	void dispose()
	{
	}
  
	void displayIn(Element container) async
	{
	}

	void _refreshClick(MouseEvent e)
	{
		_data.reload();
	}

	void _saveClick(MouseEvent e)
	{
	}  
}
