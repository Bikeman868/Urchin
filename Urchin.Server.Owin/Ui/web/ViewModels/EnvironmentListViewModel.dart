import '../MVVM/ListBinding.dart';
import '../MVVM/ViewModel.dart';
import '../MVVM/ChangeState.dart';

import '../Models/EnvironmentModel.dart';
import '../ViewModels/EnvironmentViewModel.dart';
import '../Server.dart';

class EnvironmentListViewModel extends ViewModel
{
    ListBinding<EnvironmentModel, EnvironmentViewModel> environments;

	EnvironmentListViewModel([List<EnvironmentModel> environmentModels])
	{
		environments = new ListBinding<EnvironmentModel, EnvironmentViewModel>(
			(Map json) => new EnvironmentModel(new Map()..['name']='ENVIRONMENT'), 
			(EnvironmentModel m) => new EnvironmentViewModel(m));

		if (environmentModels == null)
			Server.getEnvironments().then((List<EnvironmentModel> m) => models = m);
		else
			models = environmentModels;
	}

	dispose()
	{
		models = null;
	}

	List<EnvironmentModel> get models
	{
		return environments.models;
	}

	void set models(List<EnvironmentModel> value)
	{
		environments.models = value;
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
}
