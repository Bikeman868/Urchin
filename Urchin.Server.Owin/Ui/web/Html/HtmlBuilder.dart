import 'dart:html';

class HtmlBuilder
{
	List<Element> _elements;

	HtmlBuilder()
	{
		_elements = new List<Element>();
	}

	displayIn(Element container)
	{
		container.children.clear();
		addTo(container);
	}

	addTo(Element container)
	{
		for (var e in _elements)
			container.children.add(e);
	}

	Element addInlineText(
		String html, 
		{
			List<String> classNames, 
			String className, 
			Element parent
		})
	{
		var label = new SpanElement();
		if (html != null)
    		label.innerHtml = html;
		return _addElement(label, classNames, className, parent);
	}

	Element addBlockText(
		String html, 
		{
			List<String> classNames, 
			String className, 
			Element parent
		})
	{
		var div = new DivElement();
		if (html != null)
			div.innerHtml = html;
		return _addElement(div, classNames, className, parent);
	}
  
	Element addContainer(
		{
			List<String> classNames, 
			String className, 
			Element parent
		})
	{
		var div = new DivElement();
		return _addElement(div, classNames, className, parent);
	}
    
	Element addButton(
		String html, 
		EventListener onClick,
		{
			List<String> classNames, 
			String className, 
			Element parent
		})
	{
		var button = new SpanElement();
		button.classes.add('button');
		if (html != null)
    		button.innerHtml = html;
		if (onClick != null)
    		button.onClick.listen(onClick);
		return _addElement(button, classNames, className, parent);
	}
  
	Element addInput(
		{
		  List<String> classNames, 
		  String className, 
		  Element parent
		})
	{
		var input = new InputElement();
		return _addElement(input, classNames, className, parent);
	}

	Element addPassword(
		{
			List<String> classNames, 
			String className, 
			Element parent
		})
	{
		var input = new PasswordInputElement();
		return _addElement(input, classNames, className, parent);
	}

	Element addList(
		{
			List<String> classNames, 
			String className, 
			Element parent
		})
	{
		var list = new UListElement();
		return _addElement(list, classNames, className, parent);
	}

	Element _addElement(
		Element element,
		List<String> classNames, 
		String className, 
		Element parent)
	{
		if (className != null && !className.isEmpty)
			element.classes.add(className);
    
		if (classNames != null)
			for (var c in classNames)
				element.classes.add(c);

		if (parent == null)
			_elements.add(element);
		else
			parent.children.add(element);

		return element;
	}
}
