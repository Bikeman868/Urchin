import '../DataBinding/StringBinding.dart';
import '../DataBinding/ListBinding.dart';
import '../DataBinding/ViewModel.dart';
import '../DataBinding/ChangeState.dart';

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
		this.model = model;
	}

	RuleModel _model;

	RuleModel get model
	{
		if (_model != null)
		{
			_model.variables = variables.models;
		}
		return _model;
	}

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
			machine.getter = null;

			application.setter = (String text) 
			{ 
				value.application = text;
				modified();
			};
			application.getter = null;

			environment.setter = (String text) 
			{ 
				value.environment = text;
				modified();
			};
			environment.getter = null;

			instance.setter = (String text) 
			{ 
				value.instance = text;
				modified();
			};
			instance.getter = null;

			config.setter = (String text) 
			{ 
				value.config = text;
				modified();
			};
			config.getter = null;

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