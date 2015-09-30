import 'dart:async';
import 'dart:html';

void main() 
{
  int value;
  
  int getter() => i;
  
  Binding<int> binding = new Binding<int>();
  
  binding.getter = () => value;
  binding.setter = (int i) 
  {
    if (i > 100) i = 100;
    if (i < 0) i = 0;
    value = i;
  };
  binding.formatter = (int i) => i.toString();
  binding.parser = (String text) => int.parse(text);
  
  InputElement input1 = new InputElement();
  InputBinding input1Binding = new InputBinding(binding, input1);
  
  InputElement input2 = new InputElement();
  InputBinding input2Binding = new InputBinding(binding, input2);
  
  var middleDiv = querySelector('#middleDiv');
  middleDiv.children.add(input1);
  middleDiv.children.add(input2);
}

typedef String FormatFunction<T>(T value);
typedef T ParseFunction<T>(String value);
typedef T PropertyGetter<T>();
typedef void PropertySetter<T>(T value);

class Binding<T>
{
  PropertyGetter<T> getter;
  PropertySetter<T> setter;
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

class InputBinding<T>
{
  Binding<T> binding;
  InputElement input;
  
  StreamSubscription<String> _onChangeSubscription;
  
  InputBinding(Binding<T> binding, InputElement input)
  {
    this.binding = binding;
    this.input = input;
    
    input.onBlur.listen(_onBlur);
    _onChangeSubscription = binding.onChange.listen(_onChange);
  }
  
  void dispose()
  {
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

class SubscriptionEvent<E>
{
	StreamController<E> _controller = new StreamController.broadcast();
  
	raise(E e)
	{
		_controller.add(e);
	}

	StreamSubscription<E> listen(void handler(E e)) 
	{
		return _controller.stream.listen(handler);
	}
}
