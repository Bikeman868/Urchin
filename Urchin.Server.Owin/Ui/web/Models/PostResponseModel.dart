import '../MVVM/Model.dart';

class PostResponseModel extends Model
{
	PostResponseModel(Map json) : super(json);

	bool get success => getProperty('success');
	String get error => getProperty('error');
	int get id => getProperty('id');

	String toString() => 'post success ' + success.toString();
}
