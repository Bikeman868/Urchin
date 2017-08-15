import 'dart:html';

import '../../MVVM/Mvvm.dart';
import '../../Events/AppEvents.dart';

class ToolBarView extends View
{
	ToolBarView()
	{
		_addButton('Datacenters');
		_addButton('Applications');
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
