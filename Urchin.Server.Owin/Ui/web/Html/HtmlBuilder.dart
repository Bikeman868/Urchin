import 'dart:html';

class HtmlBuilder
{
	List<Element> _elements;
	String _version;

	HtmlBuilder()
	{
		_elements = new List<Element>();
		InputElement version = querySelector('#version');
		_version = version.value;
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

	Element addHeading(
		int level,
		String text, 
		{
			List<String> classNames, 
			String className, 
			Element parent
		})
	{
		var heading = new Element.html('<h' + level.toString() + '>' + text + '</h' + level.toString() + '>');
		return _addElement(heading, classNames, className, parent);
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
  
	String versioned(String url)
	{
		return url.replaceAll(r'{_v_}', _version);
	}

	Element addImage(
		String url, 
		{
			String altText,
			String popupText,
			List<String> classNames, 
			String className, 
			Element parent,
			EventListener onClick
		})
	{
		var img = new ImageElement();
		if (url != null)
			img.src = url.replaceAll(r'{_v_}', _version);
		if (onClick != null)
			img.onClick.listen(onClick);
		if (altText != null)
			img.alt = altText;
		return _addElement(img, classNames, className, parent);
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
    
	TableElement addTable(
		{
			List<String> classNames, 
			String className, 
			Element parent
		})
	{
		var table = new TableElement();
		return _addElement(table, classNames, className, parent);
	}
    
	TableRowElement addTableRow(
		TableElement table,
		{
			String rowClassName,
			List<Object> columns,
			String cellClassName
		})
	{
		var row = table.addRow();
		if (rowClassName != null && !rowClassName.isEmpty)
			row.classes.add(rowClassName);

		if (columns != null)
		{
			for (var column in columns)
			{
				addTableCell(row, cell: column, className: cellClassName);
			}
		}
		return row;
	}

	TableCellElement addTableCell(
		TableRowElement row,
		{
			String cell,
			String className
		})
	{
		var cellElement = row.addCell();
		if (cell != null)
			cellElement.innerHtml = cell;
		if (className != null && !className.isEmpty)
			cellElement.classes.add(className);
		return cellElement;
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

	Element addListElement(String html, Element parent,
		{
			List<String> classNames, 
			String className
		})
	{
		var listElement = new LIElement();
		listElement.innerHtml = html;
		return _addElement(listElement, classNames, className, parent);
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
