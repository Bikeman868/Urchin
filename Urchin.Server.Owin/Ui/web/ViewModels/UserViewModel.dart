import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../Server.dart';

import '../MVVM/ViewModel.dart';
import '../MVVM/StringBinding.dart';

import '../Models/ClientCredentialsModel.dart';
import '../Models/PostResponseModel.dart';

import '../Events/AppEvents.dart';

class UserViewModel extends ViewModel
{
    StringBinding userName;
    StringBinding ipAddress;

	String _userName;
	String _ipAddress;

	UserViewModel()
	{
		userName = new StringBinding();
		ipAddress = new StringBinding();

		userName.setter = (String text) => _userName = text;
		userName.getter = () => _userName;

		ipAddress.setter = (String text) => _ipAddress = text;
		ipAddress.getter = () => _ipAddress;

		getLoggedInUser();
	}

	void dispose()
	{
	}

	Future<bool> logIn(String userName, String password) async
	{
		var request = await Server.logon(userName, password);
		if (request.status == 200)
		{
			Map json = JSON.decode(request.responseText);
			var postResponse = new PostResponseModel(json);
			if (postResponse.success)
			{
				getLoggedInUser();
				return true;
			}
			else
			{
				window.alert(postResponse.error);
			}
		}
		return false;
	}

	Future<Null> logOut() async
	{
		var request = await Server.logoff();
		AppEvents.userChanged.raise(new UserChangedEvent(false, null, null));
		return null;
	}

	Future<Null> getLoggedInUser() async
	{
		var user = await Server.getLoggedOnUser();

		if (user.userName == null || !user.isLoggedOn)
			userName.setProperty('[logged out]');
		else
			userName.setProperty(user.userName);

		ipAddress.setProperty(user.ipAddress);

		AppEvents.userChanged.raise(
			new UserChangedEvent(user.isLoggedOn, user.userName, user.ipAddress));

		return null;
	}
}
