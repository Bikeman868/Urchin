import 'dart:html';
import 'BoundElement.dart';

class BoundLabel<T> extends BoundElement<T, Element>
{
	void _onBindingChange(String text)
	{
		if (_element != null)
			_element.innerHtml = text;
	}

	StreamSubscription<Event> _subscribeToElement(TE element)
	{
		return null;
	}
}
