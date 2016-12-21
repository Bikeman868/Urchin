import 'dart:html';

import '../../MVVM/SubscriptionEvent.dart';
import '../../MVVM/View.dart';
import '../../MVVM/BoundLabel.dart';
import '../../MVVM/BoundTextInput.dart';

import '../../Events/AppEvents.dart';

import '../../Models/SecurityRuleModel.dart';

import '../../ViewModels/SecurityRuleViewModel.dart';

class SecurityRuleListElementView extends View
{
	InputElement startIp;
	InputElement endIp;

	BoundTextInput _startIpBinding;
	BoundTextInput _endIpBinding;

	SecurityRuleListElementView([SecurityRuleViewModel viewModel])
	{
		addInlineText('Allowed IP from');
		startIp = addInput(classNames: ['ip-address', 'input-field']);
		addInlineText('to');
		endIp = addInput(classNames: ['ip-address', 'input-field']);

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
}