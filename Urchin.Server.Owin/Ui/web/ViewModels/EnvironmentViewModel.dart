import '../DataBinding/Binding.dart';
import '../Models/EnvironmentDto.dart';

class EnvironmentViewModel
{
    StringBinding name = new StringBinding();
    IntBinding version = new IntBinding();

	void dispose()
	{
		name.dispose();
		version.dispose();
	}

	EnvironmentDto _environmentModel;
	EnvironmentViewModel get environmentModel => _environmentModel;
	void set environmentModel(EnvironmentDto value)
	{
        name.setter = (String text) { value.name = text; };
        name.getter = () => value.name;
        
        version.setter = (int i) { value.version = i; };
        version.getter = () => value.version;
	}

}