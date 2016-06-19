import 'dart:html';
import 'HtmlBuilder.dart';

class FormBuilder
{
	HtmlBuilder _builder;
	Element form;

	FormBuilder()
	{
		_builder = new HtmlBuilder();
		form = _builder.addContainer(className: 'dataForm');
	}

	addTo(Element container)
	{
		_builder.addTo(container);
	}

	displayIn(Element container)
	{
		_builder.displayIn(container);
	}

	Element addLabeledField(String label)
	{
		var row = _builder.addContainer(parent: form, className: 'dataRow');

		var labelField = _builder.addInlineText(label, parent: row, className: 'dataLabel');
		var dataField = _builder.addInlineText('', parent: row, className: 'dataField');

		return dataField;
	}

	Element addLabeledEdit(String label)
	{
		var row = _builder.addContainer(parent: form, className: 'dataRow');

		var labelField = _builder.addInlineText(label, parent: row, className: 'dataLabel');
		var dataField = _builder.addInput(parent: row, className: 'inputField');

		return dataField;
	}

	Element addHeading(String label, int level)
	{
		var className = null;
		if (level == 1)
			className = 'panelTitle';
		else if (level == 2)
			className = 'panelSubHeading';

		var heading = _builder.addBlockText(label, className: className);

		form = _builder.addContainer(className: 'dataForm');

		return heading;
	}

	Element addContainer()
	{
		return _builder.addContainer();
	}

	List<Element> addButtons(List<String> text, List<EventListener> onClickMethod)
	{
		var row = _builder.addContainer(parent: form, className: 'dataRow');
		var labelField = _builder.addInlineText('&nbsp;', parent: row, className: 'dataLabel');

		var buttonDiv = _builder.addContainer(parent: row);
		var buttons = new List<Element>();
		for (var i = 0; i < text.length; i++)
		{
			var button = _builder.addButton(text[i], onClickMethod[i], parent: buttonDiv, className: 'formButton');
			buttons.add(button);
		}

		return buttons;
	}

	Element addList(String className)
	{
		return _builder.addList(className: className);
	}
}