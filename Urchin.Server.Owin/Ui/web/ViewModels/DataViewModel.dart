import '../DataBinding/ListBinding.dart';
import '../DataBinding/ViewModel.dart';
import '../DataBinding/ChangeState.dart';

import '../Models/DataModel.dart';
import '../Models/EnvironmentModel.dart';
import '../Models/VersionModel.dart';

import '../ViewModels/EnvironmentViewModel.dart';
import '../ViewModels/VersionViewModel.dart';

import '../Events/AppEvents.dart';

class DataViewModel extends ViewModel
{
    ListBinding<EnvironmentModel, EnvironmentViewModel> environments;
    ListBinding<VersionModel, VersionViewModel> versions;

	DataViewModel([DataModel model])
	{
		environments = new ListBinding<EnvironmentModel, EnvironmentViewModel>(
			(Map json) => new EnvironmentModel(new Map()..['name']='Environment'..['version']=1), 
			(EnvironmentModel m) => new EnvironmentViewModel(m));
		environments.onAdd.listen(_environmentAdded);

		versions = new ListBinding<VersionModel, VersionViewModel>(
			(Map json) => new VersionModel(new Map()..['name']='New Version', true), 
			(VersionModel m) => new VersionViewModel(m));
		versions.onAdd.listen(_versionAdded);

		this.model = model;
	}

	DataModel _model;

	DataModel get model
	{
		if (_model != null)
		{
			_model.environments = environments.models;
			_model.versions = versions.models;
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

		if (versions.getState() != ChangeState.unmodified)
			return ChangeState.modified;

		return ChangeState.unmodified;
	}

	void _environmentAdded(ListEvent e)
	{
		var viewModel = environments.viewModels[e.index];
		AppEvents.environmentSelected.raise(new EnvironmentSelectedEvent(viewModel));
	}

	void _versionAdded(ListEvent e)
	{
		var viewModel = versions.viewModels[e.index];
		AppEvents.versionSelected.raise(new VersionSelectedEvent(viewModel));
	}

}
