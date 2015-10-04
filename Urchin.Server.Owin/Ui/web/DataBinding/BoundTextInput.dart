import 'dart:html';
import 'dart:async';

import '../DataBinding/Binding.dart';
import '../DataBinding/BoundElement.dart';
import '../Events/SubscriptionEvent.dart';

class BoundTextInput<T> extends BoundElement<T, InputElement>
{
	BoundTextInput (InputElement element)
	{
		this.element = element;
	}
	
	void onBindingChange(String text)
	{
		if (element != null)
			element.value = text;
	}

	StreamSubscription<Event> subscribeToElement(InputElement element)
	{
		return element.onBlur.listen(_onBlur);
	}
  
	void _onBlur(Event e)
	{
		if (!binding.setProperty(element.value))
			e.preventDefault();
	}
}
