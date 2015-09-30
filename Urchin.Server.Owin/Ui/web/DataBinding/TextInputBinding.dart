import 'dart:html';
import 'Binding.dart';

class TextInputBinding<T>
{
	Binding<T> binding;
	InputElement input;
  
	StreamSubscription<String> _onChangeSubscription;
	StreamSubscription<Event> _onBlurSubscription;
  
	InputBinding(Binding<T> binding, InputElement input)
	{
		this.binding = binding;
		this.input = input;
    
		_onBlurSubscription = input.onBlur.listen(_onBlur);
		_onChangeSubscription = binding.onChange.listen(_onChange);
	}
  
	void dispose()
	{
		_onBlurSubscription.cancel();
		_onBlurSubscription = null;

		_onChangeSubscription.cancel();
		_onChangeSubscription = null;
	}
  
	void _onBlur(Event e)
	{
		if (!binding.setProperty(input.value))
			e.preventDefault();
	}
  
	void _onChange(String text)
	{
		input.value = text;
	}
}
