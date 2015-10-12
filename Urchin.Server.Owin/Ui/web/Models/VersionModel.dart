import '../DataBinding/Model.dart';

class VersionModel extends Model
{
	VersionModel(Map json) : super(json);

	String get name => getProperty('name');
	set name(String value) { setProperty('name', value); }
  
	int get version => getProperty('version');
	set version(int value) { setProperty('version', value); }
}
