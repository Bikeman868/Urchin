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
	void set environmentModel(EnvironmentDto model)
	{
		_environmentModel = model;

        name.setter = (String text) { model.name = text; };
        name.getter = () => model.name;
        
        version.setter = (int i) { model.version = i; };
        version.getter = () => model.version;
	}

}