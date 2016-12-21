import '../MVVM/ListBinding.dart';
import '../MVVM/ViewModel.dart';
import '../MVVM/ChangeState.dart';

import '../Models/VersionModel.dart';
import '../ViewModels/VersionViewModel.dart';

class VersionListViewModel extends ViewModel
{
    ListBinding<VersionModel, VersionViewModel> versions;

	VersionListViewModel([List<VersionModel> versionModels])
	{
		versions = new ListBinding<VersionModel, VersionViewModel>(
			(Map json) => new VersionModel(new Map()..['name']='VERSION'), 
			(VersionModel m) => new VersionViewModel(m));

		if (versionModels == null)
			Server.getVersions().then((List<VersionModel> m) => models = m);
		else
			models = versionModels;
	}

	dispose()
	{
		models = null;
	}

	List<VersionModel> get models
	{
		return versions.models;
	}

	void set models(List<VersionModel> value)
	{
		versions.models = value;
	}

	ChangeState getState()
	{
		var state = super.getState();
		if (state != ChangeState.unmodified)
			return state;

		if (versions.getState() != ChangeState.unmodified)
			return ChangeState.modified;

		return ChangeState.unmodified;
	}

}
