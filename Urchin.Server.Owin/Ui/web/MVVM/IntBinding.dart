part of mvvm;

class IntBinding extends PropertyBinding<int>
{
	IntBinding()
	{
		formatter = (int i) => i.toString();
		parser = (String text)
		{
			try
			{
				return int.parse(text);
			}
			on Exception
			{
				return null;
			}
		};
	}
}
