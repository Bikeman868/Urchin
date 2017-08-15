part of mvvm;

// Provides two-way binding of UI elements that have a 'value' property
// and an 'onBlur' event.

class BoundTextArea<T> extends BoundElement<T, TextAreaElement>
{
	BoundTextArea (TextAreaElement element)
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

	StreamSubscription<Event> subscribeToElement(TextAreaElement element)
	{
		return element.onBlur.listen(_onBlur);
	}
  
	void _onBlur(Event e)
	{
		if (!binding.setProperty(element.value))
			e.preventDefault();
	}
}
