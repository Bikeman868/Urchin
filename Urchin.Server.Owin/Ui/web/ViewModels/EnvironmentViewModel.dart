import '../DataBinding/Binding.dart';
import '../Models/EnvironmentDto.dart';

class EnvironmentViewModel
{
    StringBinding name = new StringBinding();
    IntBinding version = new IntBinding();

	EnvironmentViewModel([EnvironmentDto model])
	{
		this.model = model;
	}

	EnvironmentDto _model;
	EnvironmentDto get model => _model;
	void set model(EnvironmentDto value)
	{
		_model = value;

        name.setter = (String text) { value.name = text; };
        name.getter = () => value.name;
        
        version.setter = (int i) { value.version = i; };
        version.getter = () => value.version;
	}
}