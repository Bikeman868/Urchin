import 'dart:html';

class FormBuilder
{
	DivElement form;

	FormBuilder(Element container)
	{
		form = new DivElement();
		form.classes.add('dataForm');

		container.children.add(form);
	}

	Element addLabeledField(String label)
	{
		var row = new DivElement();
		row.classes.add('dataRow');

		var labelField = new SpanElement();
		labelField.classes.add('dataLabel');
		labelField.text = label;
		row.children.add(labelField);

		var dataField = new SpanElement();
		dataField.classes.add('dataField');
		row.children.add(dataField);

		form.children.add(row);
		return dataField;
	}

	Element addLabeledEdit(String label)
	{
		var row = new DivElement();
		row.classes.add('dataRow');

		var labelField = new SpanElement();
		labelField.classes.add('dataLabel');
		labelField.text = label;
		row.children.add(labelField);

		var dataField = new InputElement();
		dataField.classes.add('inputField');

		var div = new DivElement();
		div.classes.add('dataField');
		div.children.add(dataField);

		row.children.add(div);

		form.children.add(row);
		return dataField;
	}

	Element addHeading(String label, int level)
	{
		var container = form.parent;

		var heading = new DivElement();
		heading.text = label;
		container.children.add(heading);

		if (level == 1)
			heading.classes.add('panelTitle');
		else if (level == 2)
			heading.classes.add('panelHeading');
		else if (level == 3)
			heading.classes.add('panelSubHeading');

		form = new DivElement();
		form.classes.add('dataForm');

		container.children.add(form);

		return heading;
	}

	Element addContainer()
	{
		var container = form.parent;

		var div = new Element.div();
		container.children.add(div);

		return div;
	}

	List<Element> addButtons(List<String> text, List<EventListener> onClickMethod)
	{
		var row = new DivElement();
		row.classes.add('dataRow');

		var labelField = new SpanElement();
		labelField.classes.add('dataLabel');
		row.children.add(labelField);

		var buttonDiv = new DivElement();
		var buttons = new List<Element>();
		for (var i = 0; i < text.length; i++)
		{
			var button = new SpanElement();
			button.text = text[i];
			button.classes.add('formButton');
			button.onClick.listen(onClickMethod[i]);

			buttons.add(button);
			buttonDiv.children.add(button);
		}
		row.children.add(buttonDiv);
		form.children.add(row);

		return buttons;
	}

	static replaceJSON(Element div, String json)
	{
		div.children.clear();
		if (json == null || json.length == 0)
		return;

		var indentLevel = 0;
		var endOfLine = false;
		var propertyName = true;
		var quote = '';
		var stateStack = new List<String>();
  
		SpanElement span = null;
    
		pushState(String state)
		{
			stateStack.insert(0, state);
		}
    
		popState()
		{
			stateStack.removeAt(0);
		}
    
		String currentState()
		{
			return stateStack[0];
		}
  
		newSpan({String className})
		{
			span = new Element.span();
			div.children.add(span);
			if (className != null && !className.isEmpty)
				span.classes.add(className);
		}
  
		lineBreak() 
		{
			if (span != null)
				div.children.add(new Element.br());
			newSpan();
			for (var i = 0; i < indentLevel; i++)
				span.innerHtml = span.innerHtml + r'&nbsp;';
			endOfLine = false;
		}
  
		append(c)
		{
			if (endOfLine) lineBreak();
			span.innerHtml = span.innerHtml + c;
		}

		for (var i = 0; i < json.length; i++)
		{
			var c = json[i];

			if (c == '\r' || c == '\n')
			{}
			else if (c == quote)
			{
				newSpan();
				if (!propertyName)
					append(c);
				quote = "";
			}
			else if (c == '"' || c == "'")
			{
				if (propertyName)
				{
					if (endOfLine) lineBreak();
					newSpan(className: 'jsonName');
				}
				else
				{
					append(c);
					newSpan(className: 'jsonString');
				}
				quote = c;
			}
			else if (quote != '')
			{
				append(c);
			}
			else
			{
				if (c == '{')
				{
					lineBreak();
					append(c);
					indentLevel = indentLevel + 3;
					lineBreak();
					propertyName = true;
					pushState('object');
				}
				else if (c == '[')
				{
					lineBreak();
					append(c);
					indentLevel = indentLevel + 3;
					lineBreak();
					propertyName = false;
					pushState('array');
				}
				else if (c == '}' || c == ']')
				{
					popState();
					indentLevel = indentLevel - 3;
					lineBreak();
					append(c);
					endOfLine = true;
    			}
				else if (c == ',')
				{
					endOfLine = false;
					append(c);
					endOfLine = true;
					propertyName = currentState() == 'object';
				}
				else if (c == ':')
				{
					append(c);
					propertyName = false;
				}
				else if (c == ' ')
				{}
				else
				{
					append(c);
				}
			}
		}
	}

}