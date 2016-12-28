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

	ImageElement _refreshButton;
	ImageElement _saveButton;
	DivElement _changesDiv;

	StreamSubscription<DataEvent> _dataLoadedSubscription;
	StreamSubscription<DataEvent> _dataSavedSubscription;
	StreamSubscription<DataEvent> _dataModifiedSubscription;

	StreamSubscription<MouseEvent> _saveClickSubscription;

	bool _isModifiedValue;
	bool get _isModified => _isModifiedValue;

	set _isModified(bool value)
	{
		if (value != _isModifiedValue)
		{
			_isModifiedValue = value;
			if (value)
			{
				_changesDiv.innerHtml = '<span class="modified">Unsaved changes</span>';
				_saveButton.src = _builder.versioned('ui/images/upload{_v_}.gif');
				_saveClickSubscription = _saveButton.onClick.listen(_saveClick);
			}
			else
			{
				_changesDiv.innerHtml = '<span class="saved">No changes';
				_saveButton.src = _builder.versioned('ui/images/upload_disabled{_v_}.gif');
				if (_saveClickSubscription != null)
				{
					_saveClickSubscription.cancel();
					_saveClickSubscription = null;
				}
			}
		}
	} 
  
	UpdateComponent(Data data)
	{
		_data = data;
		_buildUI();
	}

	void _buildUI()
	{
		_builder = new HtmlBuilder();
		
		_refreshButton = _builder.addImage('ui/images/download{_v_}.gif', onClick: _refreshClick, className: 'imageButton');
		_saveButton = _builder.addImage('', className: 'imageButton');
		_changesDiv = _builder.addBlockText('');

		_isModifiedValue = true;
		_isModified = false;

		_dataLoadedSubscription = AppEvents.dataLoadedEvent.listen(_dataLoaded);
		_dataSavedSubscription = AppEvents.dataSavedEvent.listen(_dataSaved);
		_dataModifiedSubscription = AppEvents.dataModifiedEvent.listen(_dataModified);
	}

	void dispose()
	{
	}
  
	void displayIn(Element container)
	{
		_builder.addTo(container);
	}

	void _refreshClick(MouseEvent e)
	{
		if (_isModified)
		{
			if (!window.confirm('Are you sure you want to overwrite your changes with data from the server?'))
				return;
		}
		_data.reload();
	}

	void _saveClick(MouseEvent e)
	{
		_data.save();
	}

	void _dataLoaded(DataEvent e)
	{
		_isModified = false;
	}

	void _dataSaved(DataEvent e)
	{
		_isModified = false;
	}

	void _dataModified(DataEvent e)
	{
		_isModified = true;
	}
}
