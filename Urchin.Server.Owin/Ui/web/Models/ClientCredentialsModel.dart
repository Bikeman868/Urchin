import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../DataBinding/Model.dart';

class ClientCredentialsModel extends Model
{
	ClientCredentialsModel(Map json) : super(json);

	String get ipAddress => getProperty('ip');
	bool get isAdmin => getProperty('admin');
	bool get isLoggedOn => getProperty('loggedOn');
	String get userName => getProperty('userName');
}