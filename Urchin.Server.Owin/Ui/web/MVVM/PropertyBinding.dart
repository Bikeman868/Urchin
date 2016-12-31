import 'Events.dart';
import 'Types.dart';

// Provides two-way data binding with parsing and formatting
// The binding is associated with a single data value in a model
// and many UI elements. A view model is basically a collection
// of these Binding<T> objects that connect the views to the models.
class PropertyBinding<T>
{
	SubscriptionEvent<String> onChange;
  
	String _value;
	PropertyGetFunction<T> _getter;
	PropertySetFunction<T> _setter;
	FormatFunction<T> _formatter;
	ParseFunction<T> _parser;

	PropertyBinding()
	{
		onChange = new SubscriptionEvent<String>();
	}

	PropertyGetFunction<T> get getter => _getter;
	PropertySetFunction<T> get setter => _setter;
	FormatFunction<T> get formatter => _formatter;
	ParseFunction<T> get parser => _parser;

	void set getter (PropertyGetFunction<T> value)
	{
		_getter = value;
		_broadcastChange();
	}

	void set setter (PropertySetFunction<T> value)
	{
		_setter = value;
		_broadcastChange();
	}

	void set formatter (FormatFunction<T> value)
	{
		_formatter = value;
		_broadcastChange();
	}

	void set parser (ParseFunction<T> value)
	{
		_parser = value;
		_broadcastChange();
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
    
		_broadcastChange();

		return true;
	}

	void _broadcastChange()
	{
		if (onChange != null)
		{
			String formattedValue = getProperty();
			onChange.raise(formattedValue);
		}
	}
}
