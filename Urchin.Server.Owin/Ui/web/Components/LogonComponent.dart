import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../Dto.dart';
import '../Data.dart';
import '../Server.dart';
import '../AppEvents.dart';
import '../Html/HtmlBuilder.dart';

class LogonComponent
{
	Data _data;

	Element _container;
	HtmlBuilder _loggedOnUi;
	HtmlBuilder _loggedOffUi;

	Element _userNameSpanElement;
	Element _ipAddress1;
	Element _logOnButton;
  
	InputElement _userNameInputElement;
	InputElement _passwordInputElement;
	Element _ipAddress2;
	Element _logOffButton;

	StreamSubscription<UserChangedEvent> _onUserChangedSubscription;

	LogonComponent(Data data)
	{
		_data = data;

		_buildLoggedOnUI();
		_buildLoggedOffUI();

		_onUserChangedSubscription = AppEvents.userChanged.listen(_userChanged);
	}

	void _buildLoggedOnUI()
	{
		_loggedOnUi = new HtmlBuilder();

		var table = _loggedOnUi.addTable();
		var row1 = _loggedOnUi.addTableRow(table);
		var row2 = _loggedOnUi.addTableRow(table);

		var cell1_1 = _loggedOnUi.addTableCell(row1);
		var cell1_2 = _loggedOnUi.addTableCell(row1);
		var cell2_1 = _loggedOnUi.addTableCell(row2);
		var cell2_2 = _loggedOnUi.addTableCell(row2);

		_userNameSpanElement = _loggedOnUi.addInlineText('', parent: cell1_1);
		_ipAddress1 = _loggedOnUi.addInlineText('', parent: cell2_1);
		_logOffButton = _loggedOnUi.addButton('Logoff', _logoffClick, className: 'toolBarButton', parent: cell2_2);
	}

	void _buildLoggedOffUI()
	{
		_loggedOffUi = new HtmlBuilder();

		var table = _loggedOffUi.addTable();
		var row1 = _loggedOffUi.addTableRow(table);
		var row2 = _loggedOffUi.addTableRow(table);
		var row3 = _loggedOffUi.addTableRow(table);

		var cell1_1 = _loggedOffUi.addTableCell(row1);
		var cell1_2 = _loggedOffUi.addTableCell(row1);
		var cell2_1 = _loggedOffUi.addTableCell(row2);
		var cell2_2 = _loggedOffUi.addTableCell(row2);
		var cell3_1 = _loggedOffUi.addTableCell(row3);
		var cell3_2 = _loggedOffUi.addTableCell(row3);

		_loggedOffUi.addInlineText('Username', parent: cell1_1);
	    _userNameInputElement = _loggedOffUi.addInput(className: 'inputLogon', parent: cell1_2);
		_loggedOffUi.addInlineText('Password', parent: cell2_1);
	    _passwordInputElement = _loggedOffUi.addPassword(className: 'inputLogon', parent: cell2_2);
		_ipAddress2 = _loggedOffUi.addInlineText('', parent: cell3_1);
	    _logOnButton = _loggedOffUi.addButton('Logon', _logonClick, className: 'toolBarButton', parent: cell3_2);
	}

	void dispose()
	{
		_onUserChangedSubscription.cancel();
		_onUserChangedSubscription = null;
	}
  
	void displayIn(Element container) async
	{
		_container = container;

		ClientCredentials user = await Server.getLoggedOnUser();
		var e = new UserChangedEvent(user.isLoggedOn, user.userName, user.ipAddress);
		AppEvents.userChanged.raise(e);
	}

	void _userChanged(UserChangedEvent e)
	{
		_userNameSpanElement.text = e.userName;

		if (e.ipAddress != null)
		{
			_ipAddress1.text = e.ipAddress;
			_ipAddress2.text = e.ipAddress;
		}

		if (e.isLoggedOn)
		{
			_userNameInputElement.value = e.userName;
			_loggedOnUi.displayIn(_container);
		}
		else
		{
			_loggedOffUi.displayIn(_container);
		}
	}

	void _logonClick(MouseEvent e)
	{
		var logon = Server.logon(_userNameInputElement.value, _passwordInputElement.value);
		logon
			.then((HttpRequest request) 
			{
				if (request.status == 200)
				{
					Map json = JSON.decode(request.responseText);
					var postResponse = new PostResponseDto(json);
					if (postResponse.success)
					{
						_passwordInputElement.value = '';
						AppEvents.userChanged.raise(new UserChangedEvent(true, _userNameInputElement.value, null));
					}
					else
					{
						window.alert(postResponse.error);
					}
				}
			})
			.catchError((Error error)
			{
				window.alert(error.toString());
			});
	}

	void _logoffClick(MouseEvent e)
	{
		_passwordInputElement.value = '';
		var logoff = Server.logoff();
		logoff.then((request) => _loggedOff(request));
	}

	void _loggedOff(HttpRequest request)
	{
		AppEvents.userChanged.raise(new UserChangedEvent(false, null, null));
	}
  
}
