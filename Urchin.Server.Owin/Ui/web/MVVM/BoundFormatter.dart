import 'dart:html';
import 'dart:async';

import 'BoundElement.dart';
import 'Events.dart';
import 'Types.dart';

// Provides one-way binding of a view model property to a container element
// where an external formatter is provided to parse the text and populate the
// container with HTML elements

class BoundFormatter extends BoundElement<String, Element>
{
	Formatter formatter;
	Element element;

	BoundFormatter(this.element, this.formatter)
	{
	}
	
	void onBindingChange(String text)
	{
		if (element != null)
		{
			if (text == null) text = '';
			formatter(text, element);
		}
	}

	StreamSubscription<Event> subscribeToElement(Element element)
	{
		return null;
	}
}
