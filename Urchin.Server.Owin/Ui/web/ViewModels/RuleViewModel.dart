import '../MVVM/StringBinding.dart';
import '../MVVM/ListBinding.dart';
import '../MVVM/ViewModel.dart';
import '../MVVM/ChangeState.dart';

import '../Models/RuleModel.dart';
import '../Models/VariableModel.dart';

import '../ViewModels/VariableViewModel.dart';

class RuleViewModel extends ViewModel
{
    StringBinding name = new StringBinding();
    StringBinding machine = new StringBinding();
    StringBinding application = new StringBinding();
    StringBinding environment = new StringBinding();
    StringBinding instance = new StringBinding();
    StringBinding config = new StringBinding();
    ListBinding<VariableModel, VariableViewModel> variables;

	RuleViewModel([RuleModel model])
	{
		name = new StringBinding();
		machine = new StringBinding();
		application = new StringBinding();
		environment = new StringBinding();
		instance = new StringBinding();
		config = new StringBinding();

		variables = new ListBinding<VariableModel, VariableViewModel>(
			(Map json) => new VariableModel(new Map()..['name']='MACHINE'), 
			(VariableModel m) => new VariableViewModel(m));

		this.model = model;
	}

	RuleModel _model;
	RuleModel get model	{ return _model; }

	void set model(RuleModel value)
	{
		_model = value;

		if (value == null)
		{
			name.setter = null;
			name.getter = null;

			machine.setter = null;
			machine.getter = null;

			application.setter = null;
			application.getter = null;

			environment.setter = null;
			environment.getter = null;

			instance.setter = null;
			instance.getter = null;

			config.setter = null;
			config.getter = null;

			name.setter = null;
			name.getter = null;

			variables.models = null;
		}
		else
		{
			name.setter = (String text) 
			{ 
				value.name = text;
				modified();
			};
			name.getter = () => value.name;

			machine.setter = (String text) 
			{ 
				value.machine = text;
				modified();
			};
			machine.getter = () => value.machine;

			application.setter = (String text) 
			{ 
				value.application = text;
				modified();
			};
			application.getter = () => value.application;

			environment.setter = (String text) 
			{ 
				value.environment = text;
				modified();
			};
			environment.getter = () => value.environment;

			instance.setter = (String text) 
			{ 
				value.instance = text;
				modified();
			};
			instance.getter = () => value.instance;

			config.setter = (String text) 
			{ 
				value.config = text;
				modified();
			};
			config.getter = () => value.config;

			variables.models = value.variables;
		}
	}

	ChangeState getState()
	{
		var state = super.getState();
		if (state != ChangeState.unmodified)
			return state;

		if (variables.getState() != ChangeState.unmodified)
			return ChangeState.modified;

		return ChangeState.unmodified;
	}

}