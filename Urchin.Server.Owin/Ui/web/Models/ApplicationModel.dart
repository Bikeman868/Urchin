import '../MVVM/Mvvm.dart';

class ApplicationModel extends Model
{
	ApplicationModel(Map json) : super(json);

	String get name => getProperty('name');
	set name(String value) { setProperty('name', value); }
  
	String toString() => name + ' application';
}