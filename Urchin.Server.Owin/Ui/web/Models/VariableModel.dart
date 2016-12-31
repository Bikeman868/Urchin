import '../MVVM/Model.dart';

class VariableModel extends Model
{
	VariableModel(Map json) : super(json);

	String get name => getProperty('name');
	set name(String value) { setProperty('name', value); }
  
	String get value => getProperty('value');
	set value(String value) { setProperty('value', value); }

	String toString() => name + ' variable';
}