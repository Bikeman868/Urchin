import '../Models/VersionModel.dart';
import '../Models/RuleModel.dart';

class RuleVersionModel extends VersionModel
{
	RuleVersionModel(Map json) : super(json);

	List<RuleModel> get rules => getList('rules', (json) => new RuleModel(json));
	set rules(List<RuleModel> value) { setList('rules', value); }
}
