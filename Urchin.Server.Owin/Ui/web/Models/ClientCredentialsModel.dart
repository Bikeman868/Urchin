import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../Models/ModelBase.dart';

class ClientCredentialsModel extends ModelBase
{
	ClientCredentialsModel(Map json)
	{
		Reload(json);
	}

	void Reload(Map json)
	{
		startLoading(json);
		finishedLoading();
	}

	String get ipAddress => json['ip'];
	bool get isAdmin => json['admin'];
	bool get isLoggedOn => json['loggedOn'];
	String get userName => json['userName'];
}