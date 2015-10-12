import '../DataBinding/Model.dart';

class MachineModel extends Model
{
	MachineModel(Map json) : super(json);

	String get name => getProperty('name');
	set name(String value) { setProperty('name', value); }
}
