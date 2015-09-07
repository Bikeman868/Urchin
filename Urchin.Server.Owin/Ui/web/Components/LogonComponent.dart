import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../Dto.dart';
import '../Data.dart';
import '../Server.dart';
import '../ApplicationEvents.dart';

class LogonComponent
{
	Element _container;
	List<Element> _loggedOnUi;
	List<Element> _loggedOffUi;

	Element _userNameSpanElement;
	Element _logOnButton;
  
	Element _userNameInputElement;
	Element _passwordInputElement;
	Element _logOffButton;

	LogonComponent()
	{
		_userNameSpanElement = new SpanElement();
		_logOnButton = new SpanElement();

	    _userNameInputElement = new SpanElement();
	    _passwordInputElement = new SpanElement();
	    _logOffButton = new SpanElement();

		_loggedOnUi = new List<Element>();
		_loggedOnUi.add(_userNameSpanElement);
		_loggedOnUi.add(_logOnButton);

		_loggedOffUi = new List<Element>();
		_loggedOffUi.add(_userNameInputElement);
		_loggedOffUi.add(_passwordInputElement);
		_loggedOffUi.add(_logOffButton);
	}

	void displayIn(Element container)
	{
		_container = container;
		ApplicationEvents.onUserChanged.listen(_userChanged);
		Server.getLoggedOnUser().then(user => ApplicationEvents.userChanged(user));
	}

	void _displayLoggedOn()
	{
		_container.children.clear();
		for (var element in _loggedOnUi)
			_container.children.add(element);    
	}
  
	void _displayLoggedOff()
	{
		_container.children.clear();
		for (var element in _loggedOffUi)
			_container.children.add(element);    
	}
  
	void _userChanged(UserChangedEvent e)
	{
		_userNameSpanElement.text = e.userName;

		if (e.isLoggedOn)
		{
			_userNameInputElement.text = e.userName;
			_displayLoggedOn();
		}
		else
		{
			_displayLoggedOff();
		}
	}
  }
