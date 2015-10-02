import 'dart:async';
import 'dart:html';

void main() 
{
  Model model1 = new Model();
  model1.userName = 'Martin';
  model1.ipAddress = 123;
  
  Model model2 = new Model();
  model2.userName = 'Daisy';
  model2.ipAddress = 321;
    
	ViewModel viewModel1 = new ViewModel(model1);
	ViewModel viewModel2 = new ViewModel(model2);

  View view1 = new View(viewModel1);
  View view2 = new View(viewModel1);
  
  var button1 = new ButtonElement();
  button1.text = 'Model2';
  button1.onClick.listen((Event e) { viewModel1.model = model2; });
  
  var button2 = new ButtonElement();
  button2.text = 'ViewModel2';
  button2.onClick.listen((Event e) { view1.viewModel = viewModel2; });
  
  var middleDiv = querySelector('#middleDiv');
  middleDiv.children.clear();
  middleDiv.children.add(button1);
  middleDiv.children.add(button2);
  view1.addTo(middleDiv);
  view2.addTo(middleDiv);
}

class View
{
	InputElement userName;
	BoundTextInput _userNameBinding;

	InputElement ipAddress;
	BoundTextInput _ipAddressBinding;

	View([ViewModel viewModel])
	{
    userName = new InputElement();
    ipAddress = new InputElement();

    _userNameBinding = new BoundTextInput(userName);
		_ipAddressBinding = new BoundTextInput(ipAddress);

    this.viewModel = viewModel;
		}
  
  ViewModel _viewModel;
  ViewModel get viewModel => _viewModel;
  void set viewModel(ViewModel value)
  {
    _viewModel = value;
    if (value == null)
    {
      _userNameBinding.binding = null;
      _ipAddressBinding.binding = null;
    }
    else
    {
      _userNameBinding.binding = value.userName;
      _ipAddressBinding.binding = value.ipAddress;
    }
  }
  
  void addTo(Element container)
  {
    container.children.add(userName);
    container.children.add(ipAddress);
  }
}

class ViewModel
{
    StringBinding userName = new StringBinding();
    IntBinding ipAddress = new IntBinding();

  ViewModel([Model model])
  {
    this.model = model;
  }
  
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
			_onBindingChange(value.getProperty());
			_bindingSubscription = value.onChange.listen(_onBindingChange);
		}
	}

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
			_elementSubscription = _subscribeToElement(value);
		}
		if (_binding != null)
			_onBindingChange(_binding.getProperty());
	}

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