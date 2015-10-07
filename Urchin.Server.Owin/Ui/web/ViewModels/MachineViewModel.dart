import '../DataBinding/StringBinding.dart';
import '../DataBinding/ViewModel.dart';

import '../Models/MachineModel.dart';

class MachineViewModel extends ViewModel
{
    StringBinding name = new StringBinding();

	MachineViewModel([MachineModel model])
	{
		this.model = model;
	}

	MachineModel _model;
	MachineModel get model => _model;
	void set model(MachineModel value)
	{
		_model = value;

        name.setter = (String text) { value.name = text; };
        name.getter = () => value.name;
	}
}