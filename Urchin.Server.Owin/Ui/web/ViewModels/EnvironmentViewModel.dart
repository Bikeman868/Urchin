import '../DataBinding/StringBinding.dart';
import '../DataBinding/IntBinding.dart';
import '../DataBinding/ListBinding.dart';
import '../DataBinding/ViewModel.dart';
import '../DataBinding/ChangeState.dart';

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
			(Map json) => new MachineModel(new Map()..['name']='MACHINE'), 
			(MachineModel m) => new MachineViewModel(m));

		rules = new ListBinding<SecurityRuleModel, SecurityRuleViewModel>(
			(Map json) => new SecurityRuleModel(new Map()..['startIp']='127.0.0.1'..['endIp']='127.0.0.1'), 
			(SecurityRuleModel m) => new SecurityRuleViewModel(m));

		this.model = model;
	}

	EnvironmentModel _model;
	EnvironmentModel get model
	{
		if (_model != null)
		{
			_model.machines = machines.models;
			_model.securityRules = rules.models;
		}
		return _model;
	}

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
			name.setter = (String text) 
			{ 
				value.name = text;
				modified();
			};
			name.getter = () => value.name;
        
			version.setter = (int i) 
			{ 
				value.version = i; 
				modified();
			};
			version.getter = () => value.version;

			machines.models = value.machines;
			rules.models = value.securityRules;
		}
	}

	ChangeState getState()
	{
		var state = super.getState();
		if (state != ChangeState.unmodified)
			return state;

		if (machines.getState() != ChangeState.unmodified)
			return ChangeState.modified;

		if (rules.getState() != ChangeState.unmodified)
			return ChangeState.modified;

		return ChangeState.unmodified;
	}

}
