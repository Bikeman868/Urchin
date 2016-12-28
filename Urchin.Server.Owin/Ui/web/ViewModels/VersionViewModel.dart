import 'dart:html';
import 'dart:async';

import '../MVVM/StringBinding.dart';
import '../MVVM/IntBinding.dart';
import '../MVVM/ModelListBinding.dart';
import '../MVVM/ViewModel.dart';
import '../MVVM/Enums.dart';

import '../Server.dart';

import '../Models/VersionModel.dart';
import '../Models/RuleModel.dart';
import '../Models/PostResponseModel.dart';

import '../ViewModels/RuleViewModel.dart';

class VersionViewModel extends ViewModel
{
    StringBinding name;
    IntBinding version;
	ModelListBinding<RuleModel, RuleViewModel> rules;

	VersionViewModel([VersionModel model])
	{
		name = new StringBinding();
		version = new IntBinding();

		rules = new ModelListBinding<RuleModel, RuleViewModel>(
			(Map json) => new RuleModel(new Map()..['name']='Rule'), 
			(RuleModel m) => new RuleViewModel(versionNumber, m));

		this.model = model;
	}

	VersionModel _model;
	VersionModel get model { return _model; }

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

	List<ModelListBinding> getModelLists()
	{
		return [rules];
	}

	int get versionNumber { return int.parse(version.getProperty()); }

	// Creates a copy of this version as the current draft version
	VersionViewModel createDraft()
	{
		return null;
	}

	Future<SaveResult> saveChanges(ChangeState state, bool alert) async
	{
		SaveResult result = SaveResult.unmodified;
		String alertMessage = 'No changes to version ' + version.getProperty() + ' to save';

		if (state == ChangeState.modified || state == ChangeState.added)
		{
			PostResponseModel response = await Server.updateVersion(versionNumber, _model);
			if (response.success)
			{
				alertMessage = 'Updated version ' + versionNumber.toString();
				result = SaveResult.saved;
				if (_model.hasRules)
				{
					for (var ruleViewModel in rules.viewModels)
					{
						SaveResult ruleResult = await ruleViewModel.save(false);
						if (ruleResult == SaveResult.failed)
						{
							alertMessage = 'One or more rules from version ' + version.getProperty() + ' failed to update';
							alert = true;
							result = SaveResult.failed;
						}
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

		if (alert) window.alert(alertMessage);

		return result;
	}

	void reload()
	{
	}
}
