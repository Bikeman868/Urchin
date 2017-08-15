import 'dart:html';
import 'dart:async';

import '../MVVM/Mvvm.dart';

import '../Server.dart';

import '../Models/RuleModel.dart';
import '../Models/VariableModel.dart';
import '../Models/PostResponseModel.dart';

import '../ViewModels/VariableViewModel.dart';

class RuleViewModel extends ViewModel
{
    StringBinding name = new StringBinding();
    StringBinding machine = new StringBinding();
    StringBinding application = new StringBinding();
    StringBinding environment = new StringBinding();
    StringBinding instance = new StringBinding();
    StringBinding config = new StringBinding();
    ModelList<VariableModel, VariableViewModel> variables;

	String _originalName;

	RuleViewModel([int version, RuleModel model]) : super(false)
	{
		name = new StringBinding();
		machine = new StringBinding();
		application = new StringBinding();
		environment = new StringBinding();
		instance = new StringBinding();
		config = new StringBinding();

		variables = new ModelList<VariableModel, VariableViewModel>(
			(Map json) => new VariableModel(new Map()..['name']='VARIABLE'), 
			(VariableModel m) => new VariableViewModel(m));

		this.version = version;
		this.model = model;
	}

	dispose()
	{
		model = null;
	}

	int version;

	RuleModel _model;
	RuleModel get model	=> _model; 

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

	void loaded()
	{
		_originalName = name.getProperty();
		super.loaded();
	}

	List<ModelList> getModelLists()
	{
		return [variables];
	}

	Future<SaveResult> saveChanges(ChangeState state, bool alert) async
	{
		SaveResult result = SaveResult.unmodified;
		String alertMessage = 'There are no changes to version ' + version.toString() + ' of ' + model.name;

		if (state == ChangeState.modified)
		{
			PostResponseModel response;
			if (name.getProperty() == _originalName)
				response = await Server.updateRules(version, [model]);
			else
				response = await Server.updateRenameRule(version, _originalName, model);

			if (response.success)
			{
				alertMessage = 'Version ' + version.toString() + ' of ' + model.name + ' updated';
				result = SaveResult.saved;
			}
			else
			{
				alertMessage = 'Failed to update version ' + version.toString() +
								' of ' + model.name + '. ' + response.error;
				result = SaveResult.failed;
			}
		}
		else if (state == ChangeState.deleted)
		{
			var response = await Server.deleteRule(version, _originalName);
			if (response.success)
			{
				alertMessage = 'Version ' + version.toString() + ' of ' + _originalName + ' deleted';
				result = SaveResult.saved;
			}
			else
			{
				alertMessage = 'Failed to delete version ' + version.toString() +
								' of ' + _originalName + '. ' + response.error;
				result = SaveResult.failed;
			}
		}
		else if (state == ChangeState.added)
		{
			var response = await Server.addRule(version, model);
			if (response.success)
			{
				alertMessage = 'Version ' + version.toString() + ' of ' + model.name + ' added';
				result = SaveResult.saved;
			}
			else
			{
				alertMessage = 'Failed to add version ' + version.toString() +
								' of ' + model.name + '. ' + response.error;
				result = SaveResult.failed;
			}
		}

		if (alert || result == SaveResult.failed) 
			window.alert(alertMessage);

		return result;
	}

	String toString() => _model.toString() + ' view model';
}