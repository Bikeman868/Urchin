import '../DataBinding/Binding.dart';
import '../Models/EnvironmentModel.dart';

class EnvironmentViewModel
{
    StringBinding name = new StringBinding();
    IntBinding version = new IntBinding();

	EnvironmentViewModel([EnvironmentModel model])
	{
		this.model = model;
	}

	EnvironmentModel _model;
	EnvironmentModel get model => _model;
	void set model(EnvironmentModel value)
	{
		_model = value;

        name.setter = (String text) { value.name = text; };
        name.getter = () => value.name;
        
        version.setter = (int i) { value.version = i; };
        version.getter = () => value.version;
	}
}