import '../MVVM/Mvvm.dart';

class DatacenterModel extends Model
{
	DatacenterModel(Map json) : super(json);

	String get name => getProperty('name');
	set name(String value) { setProperty('name', value); }
  
	String toString() => name + ' datacenter';
}