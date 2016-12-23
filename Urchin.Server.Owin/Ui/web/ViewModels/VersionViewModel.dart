import 'dart:html';

import '../MVVM/StringBinding.dart';
import '../MVVM/IntBinding.dart';
import '../MVVM/ListBinding.dart';
import '../MVVM/ViewModel.dart';
import '../MVVM/ChangeState.dart';

import '../Models/VersionModel.dart';
import '../Models/RuleModel.dart';
import '../Models/EnvironmentModel.dart';

import '../ViewModels/RuleViewModel.dart';
import '../ViewModels/EnvironmentViewModel.dart';

class VersionViewModel extends ViewModel
{
    StringBinding name;
    IntBinding version;
    ListBinding<EnvironmentModel, EnvironmentViewModel> environments;
	ListBinding<RuleModel, RuleViewModel> rules;

	VersionViewModel([VersionModel model])
	{
		name = new StringBinding();
		version = new IntBinding();

		rules = new ListBinding<RuleModel, RuleViewModel>(
			(Map json) => new RuleModel(new Map()..['name']='Rule'), 
			(RuleModel m) => new RuleViewModel(m));

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
	}

	ChangeState getState()
	{
		var state = super.getState();
		if (state != ChangeState.unmodified)
			return state;

		if (rules.getState() != ChangeState.unmodified)
			return ChangeState.modified;

		return ChangeState.unmodified;
	}

}
