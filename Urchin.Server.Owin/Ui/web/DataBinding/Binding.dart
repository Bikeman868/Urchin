import '../Events/SubscriptionEvent.dart';

typedef String FormatFunction<T>(T value);
typedef T ParseFunction<T>(String value);
typedef T PropertyGetFunction<T>();
typedef void PropertySetFunction<T>(T value);

// Provides two-way data binding with parsing and formatting
// The binding is associated with a single data value, but can be bound
// to multiple controls.
class Binding<T>
{
	PropertyGetFunction<T> getter;
	PropertySetFunction<T> setter;
	FormatFunction<T> formatter;
	ParseFunction<T> parser;
	SubscriptionEvent<String> onChange;
  
	Binding()
	{
		onChange = new SubscriptionEvent<String>();
	}
  
	String getProperty()
	{
		if (getter == null || formatter == null)
		return null;
    
		T value = getter();
		return formatter(value);
	}
  
	bool setProperty(String text)
	{
		if (parser == null)
			return false;
    
		T value = parser(text);
    
		if (value == null)
			return false;
    
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

class IntBinding extends Binding<int>
{
	IntBinding()
	{
		formatter = (int i) => i.toString();
		parser = (String text)
		{
			try
			{
				return int.parse(text);
			}
			on Exception
			{
				return null;
			}
		}
	}
}

class StringBinding extends Binding<String>
{
	IntBinding()
	{
		formatter = (String s) => s;
		parser = (String text) => text;
	}
}
