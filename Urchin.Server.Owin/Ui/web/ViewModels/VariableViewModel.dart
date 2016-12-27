import '../MVVM/StringBinding.dart';
import '../MVVM/ViewModel.dart';

import '../Models/VariableModel.dart';

class VariableViewModel extends ViewModel
{
    StringBinding name = new StringBinding();
    StringBinding value = new StringBinding();

	VariableViewModel([VariableModel model])
	{
		this.model = model;
	}

	VariableModel _model;

	VariableModel get model => _model;

	void set model(VariableModel value)
	{
		_model = value;

		if (value == null)
		{
			name.setter = null;
			name.getter = null;

			this.value.setter = null;
			this.value.getter = null;
		}
		else
		{
			name.setter = (String text) 
			{ 
				value.name = text; 
				modified();
			};
			name.getter = () => value.name;

			this.value.setter = (String text) 
			{ 
				value.name = text; 
				modified();
			};
			this.value.getter = () => value.name;
		}
		loaded();
	}
}