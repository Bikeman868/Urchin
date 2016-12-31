import 'dart:html';
import 'dart:async';

import 'BoundElement.dart';
import 'Events.dart';

// Provides one-way binding of a view model property containing a URL
// to the src url of an iframe.

class BoundIFrame<T> extends BoundElement<T, IFrameElement>
{
	BoundIFrame (IFrameElement element)
	{
		this.element = element;
	}
	
	void onBindingChange(String src)
	{
		if (element != null)
		{
			if (src == null)
				element.src = '';
			else
				element.src = src;
		}
	}

	StreamSubscription<Event> subscribeToElement(IFrameElement iframe)
	{
		return null;
	}
}

