import 'dart:html';

import '../MVVM/StringBinding.dart';
import '../MVVM/IntBinding.dart';
import '../MVVM/ModelListBinding.dart';
import '../MVVM/ViewModel.dart';
import '../MVVM/ChangeState.dart';

import '../Server.dart';

import '../Models/VersionModel.dart';
import '../Models/RuleModel.dart';

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

	List<ViewModel> getChildViewModels()
	{
		return rules.viewModels;
	}

	int get versionNumber { return int.parse(version.getProperty()); }

	VersionViewModel createDraft()
	{
		return null;
	}

	bool _saving;

	bool save([bool alert = true])
	{
		if (_saving) return true;
		_saving = true;

		var state = getState();

		if (state == ChangeState.modified)
		{
			Server.updateVersion(versionNumber, _model)
				.then((request) 
				{
					if (request.status == 200)
					{
						_saveRules();
						saved();
						if (alert)
							window.alert('Updated version ' + versionNumber.toString());
					}
					else
					{
						window.alert(
							'Failed to update version ' + versionNumber.toString() + '. ' + request.statusText);
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
			if (alert)
				window.alert('No changes to version ' + versionNumber.toString() + ' to save');
			_saving = false;
		}
	}

	bool _saveRules()
	{
		var hasChanges = false;
		for (var ruleViewModel in rules.viewModels)
		{
			if (ruleViewModel.save(false))
				hasChanges = true;
		}
		rules.saved();
		return hasChanges;
	}

	void reload()
	{
	}
}
