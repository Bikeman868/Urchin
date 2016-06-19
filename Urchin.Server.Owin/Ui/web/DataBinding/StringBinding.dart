import '../DataBinding/PropertyBinding.dart';

class StringBinding extends PropertyBinding<String>
{
	StringBinding()
	{
		formatter = (String s) => s;
		parser = (String text) => text;
	}
}
