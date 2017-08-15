part of mvvm;

class StringBinding extends PropertyBinding<String>
{
	StringBinding()
	{
		formatter = (String s) => s;
		parser = (String text) => text;
	}
}
