import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../Models/ModelBase.dart';
import '../Models/SecurityRuleModel.dart';
import '../Models/MachineModel.dart';

class EnvironmentModel extends ModelBase
{
	List<SecurityRuleModel> securityRules;
	List<MachineModel> machines;

	EnvironmentModel(Map json)
	{
		Reload(json);
	}

	void Reload(Map json)
	{
		startLoading(json);

		securityRules = new List<SecurityRuleModel>();
		List jsonRules = json['securityRules'];
		if (jsonRules != null)
		{
			for (Map r in jsonRules)
			{
				securityRules.add(new SecurityRuleModel(r));
			}
		}

		machines = new List<MachineModel>();
		List jsonMachines = json['machines'];
		if (jsonMachines != null)
		{
			for (String m in jsonMachines)
			{
				machines.add(new MachineModel(m));
			}
		}

		finishedLoading();
	}

	String get name => json['name'];
	set name(String value) { setProperty('name', value); }
  
	int get version => json['version'];
	set version(int value) { setProperty('version', value); }
}

