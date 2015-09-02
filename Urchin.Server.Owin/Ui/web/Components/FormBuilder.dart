import 'dart:html';

class FormBuilder
{
	DivElement form;

	FormBuilder(container)
	{
		form = new DivElement();
		form.classes.add('dataForm');

		container.children.add(form);
	}

	addLabeledField(label)
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

	addHeading(label)
	{
		var container = form.parent;

		var heading = new DivElement();
		heading.classes.add('dataTitle');
		heading.text = label;
		container.children.add(heading);

		form = new DivElement();
		form.classes.add('dataForm');

		container.children.add(form);

		return heading;
	}
}
