import 'dart:html';
import 'Binding.dart';
import 'BoundElement.dart';
import '../Events/SubscriptionEvent.dart';

class BoundTextInput<T> extends BoundElement<T, InputElement>
{
	BoundTextInput (InputElement element)
	{
		this.element = element;
	}
	
	void onBindingChange(String text)
	{
		if (_element != null)
			_element.value = text;
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
