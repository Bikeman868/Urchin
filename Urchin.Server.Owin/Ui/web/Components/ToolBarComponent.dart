import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../DataLayer/Data.dart';
import '../Events/AppEvents.dart';

class ToolBarComponent
{
	List<SpanElement> _buttons;
  
	ToolBarComponent()
	{
		_buttons = new List<SpanElement>();

		var rulesButton = _createButton('Rules');
		rulesButton.onClick.listen(_tabChanged);

		var environmentsButton = _createButton('Environments');
		environmentsButton.onClick.listen(_tabChanged);

		var testButton = _createButton('Test Query');
		testButton.onClick.listen(_tabChanged);

		var versionsButton = _createButton('Versions');
		versionsButton.onClick.listen(_tabChanged);
	}

	void displayIn(containerDiv)
	{
		for (var button in _buttons)
			containerDiv.children.add(button);    
	}
  
	SpanElement _createButton(String text)
	{
		var button = new SpanElement();
		button.text = text;
		button.classes.add('toolBarButton');

		_buttons.add(button);

		return button;
	}

	void _tabChanged(MouseEvent e)
	{
		SpanElement target = e.target;
		AppEvents.tabChanged.raise(new TabChangedEvent(target.text));
	}
  }
