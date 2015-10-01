import 'Binding.dart';

// Base class for UI elements that bind to view models
abstract class BoundElement<TB, TE>
{
	Binding<TB> get binding => _binding;
	void set binding(Binding<TB> value)
	{
		if (_bindingSubscription != null)
		{
			_bindingSubscription.cancel();
			_bindingSubscription = null;
		}
		_binding = value;
		if (value != null)
		{
			_onBindingChange(value.getProperty());
			_bindingSubscription = value.onChange.listen(_onBindingChange);
		}
	}

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
			_elementSubscription = _subscribeToElement(value);
		}
		if (_binding != null)
			_onBindingChange(_binding.getProperty());
	}

	Binding<TB> _binding;
	TE _element;
	StreamSubscription<String> _bindingSubscription;
	StreamSubscription<Event> _elementSubscription;
  
	void dispose()
	{
		binding = null;
		element = null;
	}
  
	void _onBindingChange(String text);
	StreamSubscription<Event> _subscribeToElement(Element element);
}
