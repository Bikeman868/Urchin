import 'dart:html';
import 'dart:convert';
import 'dart:async';

import 'Dto.dart';
import 'Data.dart';

class ToolBarComponent
{
	Data _data;
	List<SpanElement> _buttons;
  
	ToolBarComponent(Data data)
	{
		_data = data;

		_buttons = new List<SpanElement>();

		var rulesButton = _createButton('Rules');
		rulesButton.onClick.listen(_showRules);

		var environmentsButton = _createButton('Environments');
		environmentsButton.onClick.listen(_showEnvironments);
	}

	void displayIn(containerDiv)
	{
		containerDiv.children.clear();
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

	void _showRules(MouseEvent e)
	{
		_data.loadRuleNames();
	}
  
	void _showEnvironments(MouseEvent e)
	{
		_data.loadRuleNames();
	}
}
