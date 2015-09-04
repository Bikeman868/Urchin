import 'dart:html';
import 'dart:convert';
import 'dart:async';

import 'FormBuilder.dart';
import '../Server.dart';

class TestQueryComponent
{
	SpanElement _heading1;
	InputElement _machineInput;
	InputElement _applicationInput;
	InputElement _instanceInput;
	InputElement _environmentInput;
	List<Element> _buttons;

	SpanElement _heading2;
	Element _resultsContainer;

	void displayIn(containerDiv)
	{
		var formBuilder = new FormBuilder(containerDiv);

		_heading1 = formBuilder.addHeading('Test Query', 1);

		_machineInput = formBuilder.addLabeledEdit('Machine:');
		_applicationInput = formBuilder.addLabeledEdit('Application:');
		_instanceInput = formBuilder.addLabeledEdit('Instance:');
		_environmentInput = formBuilder.addLabeledEdit('Environment:');
		_buttons = formBuilder.addButtons(['Test'], [testClicked]);

		_heading2 = formBuilder.addHeading('Results', 1);
		_resultsContainer = formBuilder.addContainer();
	}

	testClicked(MouseEvent e)
	{
		var getConfig = Server.getConfig(
			_machineInput.value, 
			_applicationInput.value,
			_environmentInput.value,
			_instanceInput.value);

		getConfig.then((json) => FormBuilder.replaceJSON(_resultsContainer, json));
	}

}
