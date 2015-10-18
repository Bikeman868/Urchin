import '../DataBinding/Model.dart';
import '../Models/EnvironmentModel.dart';
import '../Models/RuleVersionModel.dart';

class DataModel extends Model
{
	DataModel() : super(null);

	List<EnvironmentModel> environments;
	List<RuleVersionModel> versions;
}
