import '../DataBinding/StringBinding.dart';
import '../DataBinding/IntBinding.dart';
import '../DataBinding/ListBinding.dart';
import '../DataBinding/ViewModel.dart';

import '../Models/EnvironmentModel.dart';
import '../Models/MachineModel.dart';
import '../Models/SecurityRuleModel.dart';

import '../ViewModels/MachineViewModel.dart';
import '../ViewModels/SecurityRuleViewModel.dart';

class EnvironmentViewModel extends ViewModel
{
    StringBinding name;
    IntBinding version;
    ListBinding<MachineModel, MachineViewModel> machines;
    ListBinding<SecurityRuleModel, SecurityRuleViewModel> rules;

	EnvironmentViewModel([EnvironmentModel model])
	{
		name = new StringBinding();
		version = new IntBinding();
		machines = new ListBinding<MachineModel, MachineViewModel>(
			() => new MachineModel('New Machine'), 
			(m) => new MachineViewModel(m));
		rules = new ListBinding<SecurityRuleModel, SecurityRuleViewModel>(
			() => new SecurityRuleModel(new Map()..['startIp']='127.0.0.1'..['endIp']='127.0.0.1'), 
			(m) => new SecurityRuleViewModel(m));

		this.model = model;
	}

	EnvironmentModel _model;
	EnvironmentModel get model => _model;

	void set model(EnvironmentModel value)
	{
		_model = value;

		if (value == null)
		{
			name.setter = null;
			name.getter = null;
        
			version.setter = null;
			version.getter = null;

			machines.models = null;
			rules.models = null;
		}
		else
		{
			name.setter = (String text) { value.name = text; };
			name.getter = () => value.name;
        
			version.setter = (int i) { value.version = i; };
			version.getter = () => value.version;

			machines.models = value.machines;
			rules.models = value.securityRules;
		}
	}
}
