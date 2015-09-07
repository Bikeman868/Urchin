import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../Dto.dart';
import '../Data.dart';
import '../Server.dart';
import '../ApplicationEvents.dart';
import '../Html/HtmlBuilder.dart';

class LogonComponent
{
	Data _data;

	Element _container;
	HtmlBuilder _loggedOnUi;
	HtmlBuilder _loggedOffUi;

	Element _userNameSpanElement;
	Element _logOnButton;
  
	Element _userNameInputElement;
	Element _passwordInputElement;
	Element _logOffButton;

	LogonComponent(Data data)
	{
		_data = data;

		_loggedOnUi = new HtmlBuilder();
		_userNameSpanElement = _loggedOnUi.addInlineText('');
		_logOnButton = _loggedOnUi.addButton('Logoff', _logoffClick, className: 'toolBarButton');

		_loggedOffUi = new HtmlBuilder();
		var userNameContainer = _loggedOffUi.addContainer();
		_loggedOffUi.addInlineText('Username&nbsp;', parent: userNameContainer);
	    _userNameInputElement = _loggedOffUi.addInput(className: 'inputLogon', parent: userNameContainer);
		var passwordContainer = _loggedOffUi.addContainer();
		_loggedOffUi.addInlineText('Password&nbsp;', parent: passwordContainer);
	    _passwordInputElement = _loggedOffUi.addPassword(className: 'inputLogon', parent: passwordContainer);
		var buttonContainer = _loggedOffUi.addContainer();
	    _logOffButton = _loggedOffUi.addButton('Logon', _logonClick, className: 'toolBarButton', parent: buttonContainer);

		ApplicationEvents.onUserChanged.listen(_userChanged);
	}

	void displayIn(Element container)
	{
		_container = container;

		var getLoggedOnUser = Server.getLoggedOnUser();
		getLoggedOnUser.then((userName) => ApplicationEvents.userChanged(userName));
	}

	void _userChanged(UserChangedEvent e)
	{
		_userNameSpanElement.text = e.userName;

		if (e.isLoggedOn)
		{
			_userNameInputElement.text = e.userName;
			_loggedOnUi.displayIn(_container);
		}
		else
		{
			_loggedOffUi.displayIn(_container);
		}

		var loadAll = _data.loadAll();
		loadAll.then((data) => ApplicationEvents.dataRefreshed(data));
	}

	void _logonClick(MouseEvent e)
	{
		ApplicationEvents.userChanged('Administrator');
	}
  
	void _logoffClick(MouseEvent e)
	{
		ApplicationEvents.userChanged('');
	}
  
}
