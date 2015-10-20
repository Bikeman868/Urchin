import '../DataBinding/Model.dart';
import '../Models/EnvironmentModel.dart';
import '../Models/VersionModel.dart';

class DataModel extends Model
{
	DataModel() : super(null);

	List<EnvironmentModel> environments;
	List<VersionModel> versions;
}
