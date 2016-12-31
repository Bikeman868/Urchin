import 'dart:html';

import '../../MVVM/Events.dart';
import '../../MVVM/View.dart';
import '../../MVVM/BoundLabel.dart';

import '../../Events/AppEvents.dart';

import '../../Models/SecurityRuleModel.dart';

import '../../ViewModels/SecurityRuleViewModel.dart';

class SecurityRuleListElementView extends View
{
	BoundLabel<String> _startIpBinding;
	BoundLabel<String> _endIpBinding;

	SecurityRuleListElementView([SecurityRuleViewModel viewModel])
	{
		addInlineText('Allowed IP from ');
		_startIpBinding = new BoundLabel<String>(addSpan(classNames: ['ip-address']));
		addInlineText(' to ');
		_endIpBinding = new BoundLabel<String>(addSpan(classNames: ['ip-address']));

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