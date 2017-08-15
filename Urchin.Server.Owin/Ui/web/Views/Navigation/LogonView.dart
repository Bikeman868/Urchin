import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../../MVVM/Mvvm.dart';

import '../../ViewModels/UserViewModel.dart';

import '../../Events/AppEvents.dart';

class LogonView extends View
{
	BoundLabel<String> _loggedInUserNameBinding;
	BoundLabel<String> _loggedInIpAddressBinding;
	BoundLabel<String> _loggedOutIpAddressBinding;

	Element _loggedInUi;
	Element _loggedOutUi;

	InputElement _userNameInputElement;
	InputElement _passwordInputElement;

	StreamSubscription<UserChangedEvent> _onUserChangedSubscription;

	LogonView([UserViewModel viewModel])
	{
		_loggedInUi = _buildLoggedInUi();
		_loggedOutUi = _buildLoggedOutUi();

		_onUserChangedSubscription = AppEvents.userChanged.listen(_userChanged);

		this.viewModel = viewModel;
	}

	UserViewModel _viewModel;
	UserViewModel get viewModel => _viewModel;

	void set viewModel(UserViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_loggedInUserNameBinding.binding = null;
			_loggedInIpAddressBinding.binding = null;
			_loggedOutIpAddressBinding.binding = null;
		}
		else
		{
			_loggedInUserNameBinding.binding = value.userName;
			_loggedInIpAddressBinding.binding = value.ipAddress;
			_loggedOutIpAddressBinding.binding = value.ipAddress;
		}
	}

	Element _buildLoggedInUi()
	{
		var ui = addContainer();
		hideElement(ui);

		var table = addTable(parent: ui);
	
		var row1 = addTableRow(table);
		var row2 = addTableRow(table);
		var row3 = addTableRow(table);

		var cell1_1 = addTableCell(row1);
		var cell1_2 = addTableCell(row1);
		var cell2_1 = addTableCell(row2);
		var cell2_2 = addTableCell(row2);
		var cell3_1 = addTableCell(row3);
		var cell3_2 = addTableCell(row3);

		_loggedInUserNameBinding = new BoundLabel<String>(addSpan(className: 'user-name', parent: cell1_2));
		_loggedInIpAddressBinding = new BoundLabel<String>(addSpan(parent: cell2_2));
		addButton('Logoff', _logOutClick, className: 'toolBarButton', parent: cell3_2);

		return ui;
	}

	Element _buildLoggedOutUi()
	{
		var ui = addContainer();
		hideElement(ui);

		var table = addTable(parent: ui);
		var row1 = addTableRow(table);
		var row2 = addTableRow(table);
		var row3 = addTableRow(table);

		var cell1_1 = addTableCell(row1);
		var cell1_2 = addTableCell(row1);
		var cell2_1 = addTableCell(row2);
		var cell2_2 = addTableCell(row2);
		var cell3_1 = addTableCell(row3);
		var cell3_2 = addTableCell(row3);

		addInlineText('Username', parent: cell1_1);
	    _userNameInputElement = addInput(className: 'input-logon', parent: cell1_2);
		addInlineText('Password', parent: cell2_1);
	    _passwordInputElement = addPassword(className: 'input-logon', parent: cell2_2);
		_loggedOutIpAddressBinding = new BoundLabel<String>(addInlineText('', parent: cell3_1));
	    addButton('Logon', _logInClick, className: 'tool-bar-button', parent: cell3_2);

		return ui;
	}

	void dispose()
	{
		_onUserChangedSubscription.cancel();
		_onUserChangedSubscription = null;
	}
  
	void _userChanged(UserChangedEvent e)
	{
		_setState(e.isLoggedOn);
	}

	void _setState(bool loggedIn)
	{
		if (loggedIn)
		{
			hideElement(_loggedOutUi);
			showElement(_loggedInUi);
		}
		else
		{
			hideElement(_loggedInUi);
			showElement(_loggedOutUi);
		}
	}

	void _logInClick(MouseEvent e)
	{
		_viewModel.logIn(_userNameInputElement.value, _passwordInputElement.value)
			.then((bool success) 
				{
				})
			.catchError((Error error)
				{
					window.alert(error.toString());
				});
	}

	void _logOutClick(MouseEvent e)
	{
		_passwordInputElement.value = '';
		_viewModel.logOut();
	}  
}
