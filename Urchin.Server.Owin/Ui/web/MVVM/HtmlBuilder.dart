import 'dart:html';

class HtmlBuilder
{
	List<Element> _elements;

	HtmlBuilder()
	{
		InputElement version = querySelector('#version');
		_version = version.value;

		clear();
	}

	clear()
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

	/******************************************************************************/

	String _version;

	String versioned(String url)
	{
		return url.replaceAll(r'{_v_}', _version);
	}

	/******************************************************************************/

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

	Element addLink(
		String url,
		{
			List<String> classNames, 
			String className, 
			Element parent
		})
	{
		
		var link = new Element.html('<a href="' + url + '"></a>');
		return _addElement(link, classNames, className, parent);
	}

	Element addHR(
		{
			List<String> classNames, 
			String className, 
			Element parent
		})
	{
		
		var link = new Element.html('<hr/>');
		return _addElement(link, classNames, className, parent);
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
    
	/******************************************************************************/

	Element addDiv(
		{
			String html, 
			List<String> classNames, 
			String className, 
			Element parent
		})
	{
		var div = new DivElement();
		if (html != null) div.innerHtml = html;
		return _addElement(div, classNames, className, parent);
	}

	Element addSpan(
		{
			String html, 
			List<String> classNames, 
			String className, 
			Element parent
		})
	{
		var span = new SpanElement();
		if (html != null) span.innerHtml = html;
		return _addElement(span, classNames, className, parent);
	}

	Element addIFrame(
			String url,
			{
				List<String> classNames,
				String className,
				Element parent
			})
	{
		var iFrame = new IFrameElement();
		iFrame.width = '100%';
		iFrame.height = '800';

		if (iFrame != null)
			iFrame.src = url;

		return _addElement(iFrame, classNames, className, parent);
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
		if (url != null) img.src = url.replaceAll(r'{_v_}', _version);
		if (onClick != null) img.onClick.listen(onClick);
		if (altText != null) img.alt = altText;
		return _addElement(img, classNames, className, parent);
	}
  
	/******************************************************************************/

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
			String className,
			List<Object> columns,
			String cellClassName
		})
	{
		var row = table.addRow();
		if (className != null && !className.isEmpty)
			row.classes.add(className);

		if (columns != null)
		{
			for (var column in columns)
			{
				addTableCell(row, cell: column, className: cellClassName);
			}
		}
		return row;
	}

	TableRowElement addTableHeaderRow(
		TableElement table,
		{
			String className,
			List<Object> columns,
			String cellClassName
		})
	{
		var row = table.addRow();
		if (className != null && !className.isEmpty)
			row.classes.add(className);

		if (columns != null)
		{
			for (var column in columns)
			{
				addTableHeaderCell(row, cell: column, className: cellClassName);
			}
		}
		return row;
	}

	TableCellElement addTableCell(
		TableRowElement row,
		{
			String cell,
			String className,
			List<String> classNames
		})
	{
		var cellElement = row.addCell();
		if (cell != null)
			cellElement.innerHtml = cell;
		if (className != null && !className.isEmpty)
			cellElement.classes.add(className);
		if (classNames != null)
			for (var c in classNames)
				cellElement.classes.add(c);
		return cellElement;
	}
    
	TableCellElement addTableHeaderCell(
		TableRowElement row,
		{
			String cell,
			String className,
			List<String> classNames
		})
	{
		var cellElement = row.addCell();
		if (cell != null)
			cellElement.innerHtml = cell;
		if (className != null && !className.isEmpty)
			cellElement.classes.add(className);
		if (classNames != null)
			for (var c in classNames)
				cellElement.classes.add(c);

		// dart html package does not support <th>
		cellElement.classes.add('th');

		return cellElement;
	}
    
	/******************************************************************************/

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

	/******************************************************************************/

	Element addForm(
		{
		  List<String> classNames, 
		  String className, 
		  Element parent
		})
	{
		if (classNames == null)
			classNames = new List<String>();

		if (className != null)
			classNames.add(className);

		classNames.add('data-form');

		return addContainer(parent: parent, classNames: classNames);
	}

	Element addLabeledField(Element form, String label)
	{
		var row = addContainer(parent: form, className: 'data-row');

		var labelField = addInlineText(label, parent: row, className: 'data-label');
		var dataField = addInlineText('', parent: row, className: 'data-field');

		return dataField;
	}

	Element addLabeledEdit(Element form, String label)
	{
		var row = addContainer(parent: form, className: 'data-row');

		var labelField = addInlineText(label, parent: row, className: 'data-label');
		var dataField = addInput(parent: row, className: 'input-field');

		return dataField;
	}

	/******************************************************************************/

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

	Element addListElement(
		{
			String html, 
			Element parent,
			List<String> classNames, 
			String className
		})
	{
		var listElement = new LIElement();
		if (html != null)
			listElement.innerHtml = html;
		return _addElement(listElement, classNames, className, parent);
	}

	/******************************************************************************/

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
