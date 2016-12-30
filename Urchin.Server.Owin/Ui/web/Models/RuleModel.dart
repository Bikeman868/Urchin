import '../MVVM/Model.dart';
import '../Models/VariableModel.dart';

class RuleModel extends Model
{
	RuleModel(Map json) : super(json);

	String get name => getProperty('name');
	set name(String value) { setProperty('name', value); }
  
	String get machine => getProperty('machine');
	set machine(String value) { setProperty('machine', value); }
  
	String get application => getProperty('application');
	set application(String value) { setProperty('application', value); }
  
	String get environment => getProperty('environment');
	set environment(String value) { setProperty('environment', value); }
  
	String get instance => getProperty('instance');
	set instance(String value) { setProperty('instance', value); }

	String get config => getProperty('config');
	set config(String value) { setProperty('config', value); }

	List<VariableModel> get variables => getList('variables', (json) => new VariableModel(json));
	set variables(List<VariableModel> value) { setList('variables', value); }

	String toString() => name + ' rule';
}

