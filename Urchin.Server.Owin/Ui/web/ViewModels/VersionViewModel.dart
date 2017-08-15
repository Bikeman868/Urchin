import 'dart:html';
import 'dart:async';

import '../MVVM/Mvvm.dart';

import '../Server.dart';

import '../Models/VersionModel.dart';
import '../Models/RuleModel.dart';
import '../Models/PostResponseModel.dart';

import '../ViewModels/RuleViewModel.dart';

class VersionViewModel extends ViewModel
{
    StringBinding name;
    IntBinding version;
	ModelList<RuleModel, RuleViewModel> rules;

	VersionViewModel([VersionModel model]) : super(false)
	{
		name = new StringBinding();
		version = new IntBinding();

		rules = new ModelList<RuleModel, RuleViewModel>(
			(Map json) => new RuleModel(new Map()..['name']='Rule'), 
			(RuleModel m) => new RuleViewModel(versionNumber, m));

		this.model = model;
	}

	dispose()
	{
		model = null;
	}

	VersionModel _model;
	VersionModel get model => _model;

	void set model(VersionModel value)
	{
		_model = value;

		if (value == null)
		{
			name.setter = null;
			name.getter = null;
        
			version.setter = null;
			version.getter = null;

			rules.models = null;
		}
		else
		{
			name.setter = (String text) 
			{ 
				value.name = text;
				modified();
			};
			name.getter = () => value.name;
        
			version.setter = (int i) 
			{ 
				value.version = i; 
				modified();
			};
			version.getter = () => value.version;

			rules.models = model.rules;
		}
		loaded();
	}

	List<ModelList> getModelLists()
	{
		return [rules];
	}

	int get versionNumber { return int.parse(version.getProperty()); }

	Future<SaveResult> saveChanges(ChangeState state, bool alert) async
	{
		SaveResult result = SaveResult.unmodified;
		String alertMessage;

		if (state == ChangeState.modified || state == ChangeState.added)
		{
			PostResponseModel response = await Server.updateVersion(versionNumber, _model);
			if (response.success)
			{
				alertMessage = 'Updated version ' + versionNumber.toString();
				result = SaveResult.saved;

				if (_model.hasRules)
				{
					SaveResult rulesResult = await rules.saveChanges();
					if (rulesResult == SaveResult.failed)
					{
						result = SaveResult.failed;
						alertMessage = 'Failed to update version ' + version.getProperty() + ' rules';
					}
					else if (rulesResult == SaveResult.saved)
					{
						rules.removeDeleted();
						rules.saved();
					}
				}
			}
			else
			{
				alertMessage = 'Failed to update version ' + version.getProperty() + '. ' + response.error;
				alert = true;
				result = SaveResult.failed;
			}
		}
		else if (state == ChangeState.deleted)
		{
			var response = await Server.deleteVersion(versionNumber);
			if (response.success)
			{
				result = SaveResult.saved;
			}
			else
			{
				alertMessage = 'Failed to delete version ' + version.getProperty() + ' ' + response.error;
				alert = true;
				result = SaveResult.failed;
			}
		}
		else
		{
			alertMessage = 'No changes to version ' + version.getProperty() + ' to save';
		}

		if (alert) window.alert(alertMessage);

		return result;
	}

	void reload()
	{
		if (_model == null) return;

		Server.getRules(_model.version)
			.then((VersionModel model)
			{
				this.model = model;
			})
			.catchError((e) => window.alert(e.toString()));
	}

	String toString() => _model.toString() + ' view model';
}
