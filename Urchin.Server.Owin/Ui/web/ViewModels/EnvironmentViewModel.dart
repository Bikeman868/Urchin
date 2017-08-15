import 'dart:html';
import 'dart:async';

import '../MVVM/Mvvm.dart';

import '../Models/EnvironmentModel.dart';
import '../Models/MachineModel.dart';
import '../Models/SecurityRuleModel.dart';

import '../ViewModels/MachineViewModel.dart';
import '../ViewModels/SecurityRuleViewModel.dart';

class EnvironmentViewModel extends ViewModel
{
    StringBinding name;
    IntBinding version;
    ModelList<MachineModel, MachineViewModel> machines;
    ModelList<SecurityRuleModel, SecurityRuleViewModel> securityRules;

	EnvironmentViewModel([EnvironmentModel model])
	{
		name = new StringBinding();
		version = new IntBinding();

		machines = new ModelList<MachineModel, MachineViewModel>(
			(Map json) => new MachineModel(new Map()..['name']='MACHINE'), 
			(MachineModel m) => new MachineViewModel(m));

		securityRules = new ModelList<SecurityRuleModel, SecurityRuleViewModel>(
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

	List<ModelList> getModelLists()
	{
		return [machines, securityRules];
	}

	Future<SaveResult> saveChanges(ChangeState state, bool alert) async
	{
		return SaveResult.notsaved;
	}

	String toString() => _model.toString() + ' view model';
}
