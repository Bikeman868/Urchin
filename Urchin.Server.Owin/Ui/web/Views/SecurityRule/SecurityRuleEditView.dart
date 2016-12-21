import 'dart:html';

import '../../MVVM/SubscriptionEvent.dart';
import '../../MVVM/View.dart';
import '../../MVVM/BoundTextInput.dart';

import '../../Events/AppEvents.dart';
import '../../Models/SecurityRuleModel.dart';
import '../../ViewModels/SecurityRuleViewModel.dart';

class SecurityRuleEditView extends View
{
	BoundTextInput<String> _startIpBinding;
	BoundTextInput<String> _endIpBinding;

	SecurityRuleEditView([SecurityRuleViewModel viewModel])
	{
		addInlineText('Allowed IP from');
		_startIpBinding = new BoundTextInput<String>(addInput(classNames: ['ip-address', 'input-field']));
		addInlineText('to');
		_endIpBinding = new BoundTextInput<String>(addInput(classNames: ['ip-address', 'input-field']));

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