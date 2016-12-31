import 'dart:html';
import 'dart:async';

import 'BoundElement.dart';
import 'Events.dart';
import 'Types.dart';

// Provides one-way binding of a view model property to the inner html of a UI element

class BoundLabel<T> extends BoundElement<T, Element>
{
	FormatFunction<String> formatMethod;

	BoundLabel (
		Element element,
		{
			this.formatMethod : null
		})
	{
		this.element = element;
	}
	
	void onBindingChange(String text)
	{
		if (element != null)
		{
			if (text == null)
				text = '';

			if (formatMethod == null)
				element.innerHtml = text;
			else
				element.innerHtml = formatMethod(text);
		}
	}

	StreamSubscription<Event> subscribeToElement(Element element)
	{
		return null;
	}
}

