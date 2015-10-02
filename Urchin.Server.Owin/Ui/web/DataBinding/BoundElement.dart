import 'dart:async';
import 'dart:html';
import 'Binding.dart';
import '../Events/SubscriptionEvent.dart';

// Base class for UI elements that bind to view models
abstract class BoundElement<TB, TE>
{
	StreamSubscription<String> _bindingSubscription;
	Binding<TB> _binding;
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
