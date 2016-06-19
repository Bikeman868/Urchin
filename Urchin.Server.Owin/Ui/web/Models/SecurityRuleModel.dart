import '../DataBinding/Model.dart';

class SecurityRuleModel extends Model
{
	SecurityRuleModel(Map json) : super(json);

	String get startIp => getProperty('startIp');
	set startIp(String value) { setProperty('startIp', value); }
  
	String get endIp => getProperty('endIp');
	set endIp(String value) { setProperty('endIp', value); }
}