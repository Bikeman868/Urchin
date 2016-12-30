import 'dart:html';

import '../MVVM/StringBinding.dart';
import '../MVVM/IntBinding.dart';
import '../MVVM/ModelListBinding.dart';
import '../MVVM/ViewModel.dart';
import '../MVVM/Enums.dart';

import '../Models/EnvironmentModel.dart';
import '../Models/MachineModel.dart';
import '../Models/SecurityRuleModel.dart';

import '../ViewModels/MachineViewModel.dart';
import '../ViewModels/SecurityRuleViewModel.dart';

class EnvironmentViewModel extends ViewModel
{
    StringBinding name;
    IntBinding version;
    ModelListBinding<MachineModel, MachineViewModel> machines;
    ModelListBinding<SecurityRuleModel, SecurityRuleViewModel> securityRules;

	EnvironmentViewModel([EnvironmentModel model])
	{
		name = new StringBinding();
		version = new IntBinding();

		machines = new ModelListBinding<MachineModel, MachineViewModel>(
			(Map json) => new MachineModel(new Map()..['name']='MACHINE'), 
			(MachineModel m) => new MachineViewModel(m));

		securityRules = new ModelListBinding<SecurityRuleModel, SecurityRuleViewModel>(
			(Map json) => new SecurityRuleModel(new Map()..['startIp']='127.0.0.1'..['endIp']='127.0.0.1'), 
			(SecurityRuleModel m) => new SecurityRuleViewModel(m));

		this.model = model;
	}

	dispose()
	{
		model = null;
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
			securityRules.models = null;
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
			securityRules.models = value.securityRules;
		}
		loaded();
	}

	List<ModelListBinding> getModelLists()
	{
		return [machines, securityRules];
	}

}
