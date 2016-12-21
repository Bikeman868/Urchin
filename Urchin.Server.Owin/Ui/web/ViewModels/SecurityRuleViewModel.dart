import '../MVVM/StringBinding.dart';
import '../MVVM/ViewModel.dart';

import '../Models/SecurityRuleModel.dart';

class SecurityRuleViewModel extends ViewModel
{
    StringBinding startIp = new StringBinding();
    StringBinding endIp = new StringBinding();

	SecurityRuleViewModel([SecurityRuleModel model])
	{
		this.model = model;
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
	}
}