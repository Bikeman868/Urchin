import 'dart:html';

import '../MVVM/StringBinding.dart';
import '../MVVM/ModelListBinding.dart';
import '../MVVM/ViewModel.dart';
import '../MVVM/ChangeState.dart';

import '../Server.dart';

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
    ModelListBinding<VariableModel, VariableViewModel> variables;

	RuleViewModel([int version, RuleModel model])
	{
		name = new StringBinding();
		machine = new StringBinding();
		application = new StringBinding();
		environment = new StringBinding();
		instance = new StringBinding();
		config = new StringBinding();

		variables = new ModelListBinding<VariableModel, VariableViewModel>(
			(Map json) => new VariableModel(new Map()..['name']='MACHINE'), 
			(VariableModel m) => new VariableViewModel(m));

		this.version = version;
		this.model = model;
	}

	int version;

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
		loaded();
	}

	List<ViewModel> getChildViewModels()
	{
		return variables.viewModels;
	}

	bool _saving;

	bool save([bool alert = true])
	{
		if (_saving) return true;
		_saving = true;

		var state = getState();

		if (state == ChangeState.modified)
		{
			var modelsToUpdate = new List<RuleModel>();
			modelsToUpdate.add(_model);
			Server.updateRules(version, modelsToUpdate)
				.then((request)
				{
					if (request.status == 200)
					{
						saved();
						if (alert) 
							window.alert('Version ' + version.toString() + ' of ' + _model.name + ' updated');
					}
					else
					{
						window.alert(
							'Failed to update version ' + version.toString() +
							 ' of ' + _model.name + '. ' + request.statusText);
					}
					_saving = false;
				})
				.catchError((Error error) 
				{
					 window.alert(error.toString());
					 _saving = false;
				});
		}
		else if (state == ChangeState.deleted)
		{
			Server.deleteRule(version, _model.name)
				.then((request)
				{
					if (request.status == 200)
					{
						saved();
						if (alert) 
							window.alert('Version ' + version.toString() + ' of ' + _model.name + ' deleted');
					}
					else
					{
						window.alert(
							'Failed to delete version ' + version.toString() +
							 ' of ' + _model.name + '. ' + request.statusText);
					}
					_saving = false;
				})
				.catchError((Error error) 
				{
					 window.alert(error.toString());
					 _saving = false;
				});
		}
		else if (state == ChangeState.added)
		{
			Server.addRule(version, _model)
				.then((request)
				{
					if (request.status == 200)
					{
						saved();
						if (alert) 
							window.alert('Version ' + version.toString() + ' of ' + _model.name + ' added');
					}
					else
					{
						window.alert(
							'Failed to add version ' + version.toString() +
							 ' of ' + _model.name + '. ' + request.statusText);
					}
					_saving = false;
				})
				.catchError((Error error) 
				{
					 window.alert(error.toString());
					 _saving = false;
				});
		}
		else
		{
			_saving = false;
			return false;
		}

		return true;
	}

}