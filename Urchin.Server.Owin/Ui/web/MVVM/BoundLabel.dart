import 'dart:html';
import 'dart:async';
import 'BoundElement.dart';
import 'SubscriptionEvent.dart';

class BoundLabel<T> extends BoundElement<T, Element>
{
	BoundLabel (Element element)
	{
		this.element = element;
	}
	
	void onBindingChange(String text)
	{
		if (element != null)
		{
			if (text == null)
				element.innerHtml = '';
			else
				element.innerHtml = text;
		}
	}

	StreamSubscription<Event> subscribeToElement(Element element)
	{
		return null;
	}
}

