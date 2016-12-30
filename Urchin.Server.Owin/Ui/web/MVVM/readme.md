# MVVM Framework for Dart

Model - View - ViewModel

## Model

Model classes provide a mapping between a set of strongly typed properties and a Dart `Map` object. 
These models are mostly there to allow easy serialization and deserialization of JSON which the Dart libraries are very bad at.

Model classes should extend `Model` and add properties that map to elements of JSON like this:

import 'Model.dart';

```
    class VersionNameModel extends Model
    {
    	VersionNameModel(Map json) : super(json);
    
    	String get name => getProperty('name');
    	set name(String value) { setProperty('name', value); }
      
    	int get version => getProperty('version');
    	set version(int value) { setProperty('version', value); }
    }
```

In Dart when you make an HTTP request you will receive a `Map` as the result. Pass this map to the
model constructor to deserialize the JSON into a strongly typed object. For example:

```
    static Future<VersionNameModel> getVersionName(int version)  async
    {
    	String response = await HttpRequest.getString('/version/name/' + version.toString());
    	return new VersionNameModel(JSON.decode(response));
    }
```

When you want to serialize a model to pass it back to the server, the `json` property of `Model` is a `Map` that
you can pass to the `JSON.encode()` method of the Dart libraries to turn it into a `String`. For example:

```
	static Future<HttpRequest> addRule(RuleModel rule)
	{
		return HttpRequest.request('/rule', 
			method: 'POST',
			sendData: JSON.encode(rule.json),
			mimeType: 'application/json');
	}
```

Models can contain lists of other models. For example:

```
    import 'Model.dart';
    
    class MachineModel extends Model
    {
    	MachineModel(Map json) : super(json);
    
    	String get name => getProperty('name');
    	set name(String value) { setProperty('name', value); }
    }
    
    class EnvironmentModel extends Model
    {
    	EnvironmentModel(Map json) : super(json);
    
    	String get name => getProperty('name');
    	set name(String value) { setProperty('name', value); }
      
    	List<MachineModel> get machines => getList('machines', (json) => new MachineModel(json));
    	set machines(List<MachineModel> value) { setList('machines', value); }
    }
```

In this case the serialization and deserialization to/from the server is slighty more involved. For example:

```
    static Future<List<EnvironmentModel>> getEnvironments() async
    {
    	String response = await HttpRequest.getString('/environments');
    	List<Map> environmentsJson = JSON.decode(response);
    
    	var environments = new List<EnvironmentModel>();
    	for (Map environmentJson in environmentsJson)
    	{
    		environments.add(new EnvironmentModel(environmentJson));
    	}
    	return environments;
    }
    
    static Future<String> replaceEnvironments(List<EnvironmentModel> environments) async
    {
    	var requestBody = environments.map((EnvironmentModel m) => m.json).toList();

    	var httpResponse = await HttpRequest.request('/environments',
    		method: 'PUT',
    		sendData: JSON.encode(requestBody),
    		mimeType: 'application/json',
    		responseType: 'application/json');

    	Map responseJson = JSON.decode(httpResponse.responseText);
    	if (responseJson['success']) return null;
    	return responseJson['error'];
    }
    
```

## View Model

A view model provides a set of bindable properties, and connects the views to back-end services.

The View model should:
* Retrieve models from the back-end services.
* Track changes, additions and deletions.
* Save changes to back-end services.
* Expose public properties that views can bind to. When views are bound to the same view
  model they should remain in sync, i.e. changes made in one view will be immediately
  reflected in all other views.

To create a view model, write a class that extends `ViewModel`, for example:

```
    import 'StringBinding.dart';
    import 'ViewModel.dart';
    import 'MachineModel.dart';
    
    class MachineViewModel extends ViewModel
    {
        StringBinding name = new StringBinding();
    
    	MachineViewModel([MachineModel model])
    	{
    		this.model = model;
    	}
    
    	MachineModel _model;
    	MachineModel get model => _model;
    
    	void set model(MachineModel value)
    	{
    		_model = value;
    
    		if (value == null)
    		{
    			name.setter = null;
    			name.getter = null;
    		}
    		else
    		{
    			name.setter = (String text) 
    			{ 
    				value.name = text; 
    				modified();
    			};
    			name.getter = () => value.name;
    		}
    		loaded();
    	}
    }
```

This example view model accepts a `MachineModel` in its constructor then provides a bindable
`name` property that will get/set the `name` property of the model, and maintain a `ChangeState`
that alows us to check is the model was modified.

This example uses the `StringBinding` class to provide the two-way binding to the `name` property
of the model. There are also:

`StringBinding` binds to a `String` property of a model.

`IntBinding` binds to an `int` property of a model.

`ModelList` binds to a list of model objects.

## View

Views produce HTML that is bound to a view model. When the bound properties of the view model
change the HTML elements are updated with the new value and visa versa. For example:

```
import 'View.dart';
import 'BoundLabel.dart';
import 'MachineViewModel.dart';

class MachineNameView extends View
{
	BoundLabel<String> _nameLabel;

	MachineNameView([MachineViewModel viewModel])
	{
		_nameLabel = new BoundLabel<String>(
			addSpan(className: 'machine-name'),
			formatMethod: (s) => s + ' ');

		this.viewModel = viewModel;
	}

	MachineViewModel _viewModel;
	MachineViewModel get viewModel => _viewModel;

	void set viewModel(MachineViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_nameLabel.binding = null;
		}
		else
		{
			_nameLabel.binding = value.name;
		}
	}
}
```

This example constructs a `span` tag that is bound to the `name` property of a `MachineViewModel`. In this
example it also appends a space to the end of the machine name so that you can use this view in a repeater,
and it adds the css class name `machine-name` to the span so that it can be styled.

### Binding HTML in views

The example above uses the `BoundLabel<T>` class to bind the `span` tag to the view model bindable property. There are
also:

`BoundLabel<T>` provides one-way binding from a view model property to the `innerHtml` property of an html 
element. It also provides an optional lambda expression to format the html.

`BoundImage` provides one-way binding from a view model property to the `src` attribute of an image element.

`BoundIframe` provides one-way binding from a view model property to the `src` attribute of an iframe element.
 
`BoundFormatter` is designed for syntax highlighting applications where the text from the view model
property needs to be expanded into a complex nested html fragment.

`BoundRepeater` binds to `ModelList` property in the view model, and presents all of the items in the
list by constructing a view for each view model in the bound list. When items are added or removed from the list
the `BoundRepeater` will add and remove views from the UI.

`BoundList` is similar to `BoundRepeater` except that it wraps each view in a `li` and attatches `onCllick` handlers
to allow the user to choose items from the list. It can also render add/remove buttons that allow the user to
create new models with corresponding view models.

`BoundGrid` is similar to `BoundRepeater` except that it wraps each view in a `div` decorated with css classes
that can make the divs tile. It also attatches `onCllick` handlers to allow the user to choose items from the grid. 

`BoundTextInput` provides two-way bidning of the `value` attribute of an `input` element to a bindable property
of a view model.

### Constructing HTML

The example above calls the `addSpan()` method that it inherited from the `HtmlBuilder` class. In your views you
can use these methods, or any other standard Dart technique for constructing HTML elements, or finding HTML elements
in HTML templates installed with your application.