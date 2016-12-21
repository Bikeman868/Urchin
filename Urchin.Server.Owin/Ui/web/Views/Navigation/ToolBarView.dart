import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../../Events/AppEvents.dart';
import '../../MVVM/View.dart';

class ToolBarView extends View
{
	ToolBarView()
	{
		_addButton('Environments');
		_addButton('Versions');
		_addButton('Rules');
	}

	SpanElement _addButton(String text)
	{
		var button = addSpan(html: text, className: 'tool-bar-button');
		button.onClick.listen(_tabChanged);
		return button;
	}

	void _tabChanged(MouseEvent e)
	{
		SpanElement target = e.target;
		AppEvents.tabChanged.raise(new TabChangedEvent(target.text));
	}
}
