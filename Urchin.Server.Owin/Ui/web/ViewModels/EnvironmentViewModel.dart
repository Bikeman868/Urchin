import '../DataBinding/Binding.dart';
import '../Models/EnvironmentModel.dart';
import '../ViewModels/MachineViewModel.dart';
import '../ViewModels/MachineListViewModel.dart';

class EnvironmentViewModel
{
    StringBinding name = new StringBinding();
    IntBinding version = new IntBinding();

	MachineListViewModel machines = new MachineListViewModel();

	EnvironmentViewModel([EnvironmentModel model])
	{
		this.model = model;
	}

	EnvironmentModel _model;
	EnvironmentModel get model => _model;
	void set model(EnvironmentModel value)
	{
		_model = value;

		if (value == null)
		{
			name.setter = null;
			name.getter = null;
        
			version.setter = null;
			version.getter = null;

			machines.models = null;
		}
		else
		{
			name.setter = (String text) { value.name = text; };
			name.getter = () => value.name;
        
			version.setter = (int i) { value.version = i; };
			version.getter = () => value.version;

			machines.models = value.machines;
		}
	}
}
