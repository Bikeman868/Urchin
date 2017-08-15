import '../MVVM/Mvvm.dart';
import '../Models/VariableModel.dart';

class DatacenterRuleModel extends Model
{
	DatacenterRuleModel(Map json) : super(json);

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

	String get datacenterName => getProperty('datacenterName');
	set datacenterName(String value) { setProperty('datacenterName', value); }

	String toString() => name + ' datacenter rule';
}

