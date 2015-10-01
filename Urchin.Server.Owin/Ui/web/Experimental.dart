import 'dart:async';
import 'dart:html';

void main() 
{
  int value = 3;
  
  Binding<int> binding = new Binding<int>();
  binding.getter = () => value;
  binding.setter = (int i) 
  {
    if (i > 100) i = 100;
    if (i < 0) i = 0;
    value = i;
  };
  binding.formatter = (int i) => i.toString();
  binding.parser = (String text) 
  {
    try
    {
    	return int.parse(text);
    }
    on Exception
    {
      return null;
    }
  };
  
  InputElement input1 = new InputElement();
  BoundTextInput input1Binding = new BoundTextInput(input1);
  input1Binding.binding = binding;
  
  InputElement input2 = new InputElement();
  BoundTextInput input2Binding = new BoundTextInput(input2);
  input2Binding.binding = binding;
  
  var middleDiv = querySelector('#middleDiv');
  middleDiv.children.add(input1);
  middleDiv.children.add(input2);
}

class View
{
	InputElement userNameElement;
	BoundTextInput _userNameBinding;

	InputElement ipAddressElement;
	BoundTextInput _ipAddressBinding;

	View()
	{
		userNameElement = new InputElement();
		ipAddressElement = new InputElement();

		_userNameBinding = new BoundTextInput(userNameElement);
		_ipAddressBinding = new BoundTextInput(ipAddressElement);
	}

	void bind(ViewModel viewModel)
	{
		_userNameBinding.binding = viewModel.userName;
		_ipAddressBinding.binding = viewModel.ipAddress;
	}
}

class ViewModel
{
    StringBinding userName = new StringBinding();
    IntBinding ipAddress = new IntBinding();

	Model _model;
	Model get model => _model;
	void set model(Model value)
	{
			_model = model;

      userName.setter = (String text) { value.userName = text; };
      userName.getter = () => value.userName;

      ipAddress.setter = (int i) { value.ipAddress = i; };
      ipAddress.getter = () => value.ipAddress;
	}
}

class Model
{
	int ipAddress;
	bool isAdmin;
	bool isLoggedOn;
	String userName;
}

typedef String FormatFunction<T>(T value);
typedef T ParseFunction<T>(String value);
typedef T PropertyGetFunction<T>();
typedef void PropertySetFunction<T>(T value);

// Provides two-way data binding with parsing and formatting
// The binding is associated with a single data value in a model
// and many UI elements. A view model is basically a collection
// of these Binding<T> objects that connect the views to the models.
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
		};
	}
}

class StringBinding extends Binding<String>
{
	StringBinding()
	{
		formatter = (String s) => s;
		parser = (String text) => text;
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
	StreamSubscription<Event> _subscribeToElement(TE element);
}

class BoundLabel<T> extends BoundElement<T, Element>
{
	BoundLabel (Element element)
	{
		this.element = element;
	}
	
	void _onBindingChange(String text)
	{
		if (_element != null)
			_element.innerHtml = text;
	}

	StreamSubscription<Event> _subscribeToElement(Element element)
	{
		return null;
	}
}

class BoundTextInput<T> extends BoundElement<T, InputElement>
{
	BoundTextInput (InputElement element)
	{
		this.element = element;
	}
	
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
		if (!binding.setProperty(element.value))
			e.preventDefault();
	}
}