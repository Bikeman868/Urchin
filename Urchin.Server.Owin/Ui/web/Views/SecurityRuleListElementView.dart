import 'dart:html';

import '../Events/SubscriptionEvent.dart';
import '../Events/AppEvents.dart';

import '../DataBinding/View.dart';
import '../DataBinding/BoundLabel.dart';
import '../DataBinding/BoundTextInput.dart';

import '../Models/SecurityRuleModel.dart';

import '../ViewModels/SecurityRuleViewModel.dart';

class SecurityRuleListElementView extends View
{
	InputElement startIp;
	InputElement endIp;

	BoundTextInput _startIpBinding;
	BoundTextInput _endIpBinding;

	SecurityRuleListElementView([MachineViewModel viewModel])
	{
		startIp = new InputElement()
			..classes.add('ipAddress')
			..classes.add('inputField');
		endIp = new InputElement()
			..classes.add('ipAddress')
			..classes.add('inputField');

		_startIpBinding = new BoundTextInput(startIp);
		_endIpBinding = new BoundTextInput(endIp);

		this.viewModel = viewModel;
	}

	SecurityRuleViewModel _viewModel;
	SecurityRuleViewModel get viewModel => _viewModel;

	void set viewModel(SecurityRuleViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_startIpBinding.binding = null;
			_endIpBinding.binding = null;
		}
		else
		{
			_startIpBinding.binding = value.startIp;
			_endIpBinding.binding = value.endIp;
		}
	}

	void addTo(Element container)
	{
		container.children.add(new SpanElement()..text = 'Allowed IP from');
		container.children.add(startIp);
		container.children.add(new SpanElement()..text = 'to');
		container.children.add(endIp);
	}

	void displayIn(Element container)
	{
		container.children.clear();
		addTo(container);
	}
}