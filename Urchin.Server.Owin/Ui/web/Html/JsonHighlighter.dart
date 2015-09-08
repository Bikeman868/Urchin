import 'dart:html';
import 'HtmlBuilder.dart';

class JsonHighlighter
{
	static displayIn(Element div, String json)
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