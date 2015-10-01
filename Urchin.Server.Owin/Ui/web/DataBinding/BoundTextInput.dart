import 'dart:html';
import 'Binding.dart';
import 'BoundElement.dart';

class BoundTextInput<T> extends BoundElement<T, InputElement>
{
	void _onBindingChange(String text)
	{
		if (_element != null)
			_element.value = text;
	}

	StreamSubscription<Event> _subscribeToElement(InputElement element)
	{
		return element.onBlur.listen(_onBlur);
	}
  
	void _onBlur(Event e)
	{
		if (!binding.setProperty(input.value))
			e.preventDefault();
	}
}
