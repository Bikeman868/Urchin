import '../DataBinding/StringBinding.dart';
import '../DataBinding/IntBinding.dart';
import '../DataBinding/ListBinding.dart';
import '../DataBinding/ViewModel.dart';

import '../Models/EnvironmentModel.dart';
import '../Models/MachineModel.dart';

import '../ViewModels/MachineViewModel.dart';

class EnvironmentViewModel extends ViewModel
{
    StringBinding name;
    IntBinding version;
    ListBinding<MachineModel, MachineViewModel> machines;

	EnvironmentViewModel([EnvironmentModel model])
	{
		name = new StringBinding();
		version = new IntBinding();
		machines = new ListBinding<MachineModel, MachineViewModel>(
			() => new MachineModel('New Machine'), 
			(m) => new MachineViewModel(m));

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
