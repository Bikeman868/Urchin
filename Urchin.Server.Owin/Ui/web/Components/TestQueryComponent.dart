import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../Html/FormBuilder.dart';
import '../Html/JsonHighlighter.dart';
import '../Server.dart';

class TestQueryComponent
{
	FormBuilder _form;

	SpanElement _heading1;
	InputElement _machineInput;
	InputElement _applicationInput;
	InputElement _instanceInput;
	InputElement _environmentInput;
	List<Element> _buttons;

	SpanElement _heading2;
	Element _resultsContainer;

	TestQueryComponent()
	{
		_form = new FormBuilder();

		_heading1 = _form.addHeading('Test Query', 1);

		_machineInput = _form.addLabeledEdit('Machine:');
		_applicationInput = _form.addLabeledEdit('Application:');
		_instanceInput = _form.addLabeledEdit('Instance:');
		_environmentInput = _form.addLabeledEdit('Environment:');
		_buttons = _form.addButtons(['Test'], [testClicked]);

		_heading2 = _form.addHeading('Results', 1);
		_resultsContainer = _form.addContainer();
	}

	void displayIn(containerDiv)
	{
		_form.addTo(containerDiv);
	}

	testClicked(MouseEvent e)
	{
		var getConfig = Server.getConfig(
			_machineInput.value, 
			_applicationInput.value,
			_environmentInput.value,
			_instanceInput.value);

		getConfig
			.then((json) => JsonHighlighter.displayIn(_resultsContainer, json))
			.catchError((Error error) => window.alert(error.toString()));
	}

}
