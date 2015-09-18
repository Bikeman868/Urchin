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
	Element _logOnButton;
  
	InputElement _userNameInputElement;
	InputElement _passwordInputElement;
	Element _logOffButton;

	StreamSubscription<UserChangedEvent> _onUserChangedSubscription;

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

		_onUserChangedSubscription = AppEvents.userChanged.listen(_userChanged);
	}

	void dispose()
	{
		_onUserChangedSubscription.cancel();
		_onUserChangedSubscription = null;
	}
  
	void displayIn(Element container)
	{
		_container = container;

		var getLoggedOnUser = Server.getLoggedOnUser();
		getLoggedOnUser.then((userName) => AppEvents.userChanged.raise(new UserChangedEvent(userName)));
	}

	void _userChanged(UserChangedEvent e)
	{
		_userNameSpanElement.text = e.userName;

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
						AppEvents.userChanged.raise(new UserChangedEvent(true, userName: _userNameInputElement.value));
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
		AppEvents.userChanged.raise(new UserChangedEvent(false));
	}
  
}
