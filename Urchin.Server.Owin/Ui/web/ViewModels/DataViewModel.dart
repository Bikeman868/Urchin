import '../DataBinding/ListBinding.dart';
import '../DataBinding/ViewModel.dart';
import '../DataBinding/ChangeState.dart';

import '../Models/DataModel.dart';
import '../Models/EnvironmentModel.dart';
import '../Models/RuleVersionModel.dart';

import '../ViewModels/EnvironmentViewModel.dart';

import '../Events/AppEvents.dart';

class DataViewModel extends ViewModel
{
    ListBinding<EnvironmentModel, EnvironmentViewModel> environments;

	DataViewModel([DataModel model])
	{
		environments = new ListBinding<EnvironmentModel, EnvironmentViewModel>(
			(Map json) => new EnvironmentModel(new Map()..['name']='Environment'..['version']=1), 
			(EnvironmentModel m) => new EnvironmentViewModel(m));
		environments.onAdd.listen(_environmentAdded);

		this.model = model;
	}

	DataModel _model;
	DataModel get model
	{
		if (_model != null)
		{
			_model.environments = environments.models;
		}
		return _model;
	}

	void set model(DataModel value)
	{
		_model = value;

		if (value == null)
		{
			environments.models = null;
		}
		else
		{
			environments.models = value.environments;
		}
	}

	ChangeState getState()
	{
		var state = super.getState();
		if (state != ChangeState.unmodified)
			return state;

		if (environments.getState() != ChangeState.unmodified)
			return ChangeState.modified;

		return ChangeState.unmodified;
	}

	void _environmentAdded(ListEvent e)
	{
		var viewModel = environments.viewModels[e.index];
		AppEvents.environmentSelected.raise(new EnvironmentSelectedEvent(viewModel));
	}

}
