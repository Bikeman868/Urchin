import '../DataBinding/Model.dart';

import '../Models/SecurityRuleModel.dart';
import '../Models/MachineModel.dart';

class EnvironmentModel extends Model
{
	EnvironmentModel(Map json) : super(json);

	String get name => getProperty('name');
	set name(String value) { setProperty('name', value); }
  
	int get version => getProperty('version');
	set version(int value) { setProperty('version', value); }

	List<MachineModel> get machines => getList('machines', (json) => new MachineModel(json));
	set machines(List<MachineModel> value) { setList('machines', value); }

	List<SecurityRuleModel> get securityRules => getList('securityRules', (json) => new SecurityRuleModel(json));
	set securityRules(List<SecurityRuleModel> value) { setList('securityRules', value); }
}

