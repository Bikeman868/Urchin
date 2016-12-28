import 'Events.dart';
import 'Types.dart';

// Provides two-way data binding with parsing and formatting
// The binding is associated with a single data value in a model
// and many UI elements. A view model is basically a collection
// of these Binding<T> objects that connect the views to the models.
class PropertyBinding<T>
{
	PropertyGetFunction<T> getter;
	PropertySetFunction<T> setter;
	FormatFunction<T> formatter;
	ParseFunction<T> parser;
	SubscriptionEvent<String> onChange;
  
	String _value;

	PropertyBinding()
	{
		onChange = new SubscriptionEvent<String>();
	}
  
	String getProperty()
	{
		if (getter == null || formatter == null)
			return null;
    
		T value = getter();
		_value = formatter(value);
		return _value;
	}
  
	bool setProperty(String text)
	{
		if (parser == null)
			return false;

		if (text == _value)
			return true;
    
		T value = parser(text);
    
		if (value == null)
			return false;

		_value = text;

		if (setter != null)
			setter(value);
    
		if (onChange != null)
		{
			String formattedValue = getProperty();
			onChange.raise(formattedValue);
		}
		return true;
	}
}
