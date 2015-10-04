import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../Models/ModelBase.dart';

class PostResponseModel extends ModelBase
{
	PostResponseModel(Map json)
	{
		Reload(json);
	}

	void Reload(Map json)
	{
		startLoading(json);
		finishedLoading();
	}

	bool get success => json['success'];
	bool get error => json['error'];
	bool get id => json['id'];
}
