import '../DataBinding/Model.dart';
import '../Models/RuleModel.dart';

class RuleVersionModel extends Model
{
	RuleVersionModel(Map json) : super(json);

	String get name => getProperty('name');
	set name(String value) { setProperty('name', value); }
  
	int get version => getProperty('version');
	set version(int value) { setProperty('version', value); }

	bool hasRules;

	List<RuleModel> get rules 
	{
		if (hasRules) return getList('rules', (json) => new RuleModel(json));
		return null;
	}

	set rules(List<RuleModel> value) 
	{ 
		setList('rules', value);
		hasRules = true;
	}
}
