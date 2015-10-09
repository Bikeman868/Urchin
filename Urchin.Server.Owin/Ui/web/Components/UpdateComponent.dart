import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../DataLayer/Data.dart';
import '../Server.dart';
import '../Events/AppEvents.dart';
import '../Html/HtmlBuilder.dart';
import '../Events/AppEvents.dart';

class UpdateComponent
{
	Data _data;
	HtmlBuilder _builder;

	Element _refreshButton;
	Element _saveButton;
	Element _changesDiv;

	StreamSubscription<DataEvent> _dataLoadedSubscription;
	StreamSubscription<DataEvent> _dataSavedSubscription;
	StreamSubscription<DataEvent> _dataModifiedSubscription;
  
	UpdateComponent(Data data)
	{
		_data = data;
		_buildUI();
	}

	void _buildUI()
	{
		_builder = new HtmlBuilder();
		
		_refreshButton = _builder.addImage('ui/images/download{_v_}.gif', onClick: _refreshClick, className: 'imageButton');
		_saveButton = _builder.addImage('ui/images/upload{_v_}.gif', onClick: _saveClick, className: 'imageButton');
		_changesDiv = _builder.addBlockText('');

		_setState(false);

		_dataLoadedSubscription = AppEvents.dataLoadedEvent.listen(_dataLoaded);
		_dataSavedSubscription = AppEvents.dataSavedEvent.listen(_dataSaved);
		_dataModifiedSubscription = AppEvents.dataModifiedEvent.listen(_dataModified);
	}

	void dispose()
	{
	}
  
	void displayIn(Element container) async
	{
		_builder.addTo(container);
	}

	void _refreshClick(MouseEvent e)
	{
		_data.reload();
	}

	void _saveClick(MouseEvent e)
	{
		_data.save();
	}

	void _dataLoaded(DataEvent e)
	{
		_setState(false);
	}

	void _dataSaved(DataEvent e)
	{
		_setState(false);
	}

	void _dataModified(DataEvent e)
	{
		_setState(true);
	}

	_setState(bool modified)
	{
		if (modified)
			_changesDiv.innerHtml = '<span class="modified">Unsaved changes</span>';
		else
			_changesDiv.innerHtml = '<span class="saved">No changes';
	}
}
