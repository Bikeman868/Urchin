import 'dart:html';
import 'dart:async';

import 'BoundElement.dart';
import 'Events.dart';

// Provides one-way binding of a view model property containing a URL
// to the src url of an image.

class BoundImage<T> extends BoundElement<T, ImageElement>
{
	BoundImage (ImageElement element)
	{
		this.element = element;
	}
	
	void onBindingChange(String text)
	{
		if (element != null)
		{
			if (text == null)
				element.src = '';
			else
				element.src = text;
		}
	}

	StreamSubscription<Event> subscribeToElement(ImageElement image)
	{
		return null;
	}
}

