import 'dart:async';

import '../MVVM/Mvvm.dart';

import '../Models/SecurityRuleModel.dart';

class SecurityRuleViewModel extends ViewModel
{
    StringBinding startIp = new StringBinding();
    StringBinding endIp = new StringBinding();

	SecurityRuleViewModel([SecurityRuleModel model])
	{
		this.model = model;
	}

	dispose()
	{
		model = null;
	}

	SecurityRuleModel _model;
	SecurityRuleModel get model => _model;

	void set model(SecurityRuleModel value)
	{
		_model = value;

		if (value == null)
		{
			startIp.setter = null;
			startIp.getter = null;

			endIp.setter = null;
			endIp.getter = null;
		}
		else
		{
			startIp.setter = (String text) { value.startIp = text; };
			startIp.getter = () => value.startIp;

			endIp.setter = (String text) { value.endIp = text; };
			endIp.getter = () => value.endIp;
		}
		loaded();
	}

	Future<SaveResult> saveChanges(ChangeState state, bool alert) async
	{
		return SaveResult.notsaved;
	}

	String toString() => _model.toString() + ' view model';
}