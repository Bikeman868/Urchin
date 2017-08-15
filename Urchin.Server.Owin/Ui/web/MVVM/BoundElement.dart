part of mvvm;

// Base class for UI elements that bind to a view model property
// * Provides two way binding between a view model property and the UI element
// * Derrived classes must provide methods to subscribe to changes from the
//   UI element, and to update the UI element with changes from the view model

abstract class BoundElement<TB, TE>
{
	StreamSubscription<String> _bindingSubscription;
	PropertyBinding<TB> _binding;
	PropertyBinding<TB> get binding => _binding;

	void set binding(PropertyBinding<TB> value)
	{
		if (_bindingSubscription != null)
		{
			_bindingSubscription.cancel();
			_bindingSubscription = null;
		}
		_binding = value;
		if (value != null)
		{
			onBindingChange(value.getProperty());
			_bindingSubscription = value.onChange.listen(onBindingChange);
		}
	}

	StreamSubscription<Event> _elementSubscription;
	TE _element;
	TE get element => _element;

	void set element(TE value)
	{
		if (_elementSubscription != null)
		{
			_elementSubscription.cancel();
			_elementSubscription = null;
		}
		_element = value;
		if (value != null)
		{
			_elementSubscription = subscribeToElement(value);
		}
		if (_binding != null)
			onBindingChange(_binding.getProperty());
	}

	void dispose()
	{
		binding = null;
		element = null;
	}
  
	void onBindingChange(String text);
	StreamSubscription<Event> subscribeToElement(TE element);
}
