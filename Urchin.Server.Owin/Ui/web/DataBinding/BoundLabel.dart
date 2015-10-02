import 'dart:html';
import 'dart:async';
import 'BoundElement.dart';
import '../Events/SubscriptionEvent.dart';

class BoundLabel<T> extends BoundElement<T, Element>
{
	BoundLabel (Element element)
	{
		this.element = element;
	}
	
	void _onBindingChange(String text)
	{
		if (_element != null)
			_element.innerHtml = text;
	}

	StreamSubscription<Event> subscribeToElement(Element element)
	{
		return null;
	}
}

