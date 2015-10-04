import '../DataBinding/Binding.dart';
import '../Models/EnvironmentModel.dart';
import '../Models/MachineModel.dart';
import '../ViewModels/MachineViewModel.dart';

class MachineListViewModel
{
	List<MachineViewModel> machines;

	MachineListViewModel([List<MachineModel> models])
	{
		this.models = models;
	}

	List<MachineModel> _models;
	List<MachineModel> get models => _models;
	void set models(List<MachineModel> value)
	{
		_models = value;
		if (value == null)
			machines = new List<MachineViewModel>();
		else
			machines = value.map((m) => new MachineViewModel(m)).toList();
	}
}