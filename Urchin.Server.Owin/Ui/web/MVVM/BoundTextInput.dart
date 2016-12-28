import 'dart:html';
import 'dart:async';

import 'PropertyBinding.dart';
import 'BoundElement.dart';
import 'Events.dart';

// Provides two-way binding of UI elements that have a 'value' property
// and an 'onBlur' event.

class BoundTextInput<T> extends BoundElement<T, InputElement>
{
	BoundTextInput (InputElement element)
	{
		this.element = element;
	}
	
	void onBindingChange(String text)
	{
		if (element != null)
		{
			if (text == null)
				element.value = '';
			else
				element.value = text;
		}
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
