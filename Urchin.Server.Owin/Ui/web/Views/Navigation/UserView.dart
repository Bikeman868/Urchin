import 'dart:html';

import '../../MVVM/Events.dart';
import '../../MVVM/View.dart';
import '../../MVVM/BoundLabel.dart';

import '../../Events/AppEvents.dart';
import '../../ViewModels/UserViewModel.dart';

class UserView extends View
{
	BoundLabel<String> _userNameBinding;
	BoundLabel<String> _ipAddressBinding;

	UserView([UserViewModel viewModel])
	{
		_userNameBinding = new BoundLabel<String>(addDiv(className: 'user-name'));
		_ipAddressBinding = new BoundLabel<String>(addDiv(className: 'ip-address'));

		this.viewModel = viewModel;
	}

	UserViewModel _viewModel;
	UserViewModel get viewModel => _viewModel;

	void set viewModel(UserViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_userNameBinding.binding = null;
			_ipAddressBinding.binding = null;
		}
		else
		{
			_userNameBinding.binding = value.userName;
			_ipAddressBinding.binding = value.ipAddress;
		}
	}
}