import '../MVVM/Mvvm.dart';

import '../ViewModels/EnvironmentListViewModel.dart';
import '../ViewModels/VersionListViewModel.dart';
import '../ViewModels/ApplicationListViewModel.dart';
//import '../ViewModels/DatacenterListViewModel.dart';
//import '../ViewModels/DatacenterRuleListViewModel.dart';
import '../ViewModels/UserViewModel.dart';

class DataViewModel extends ViewModel
{
	dispose()
	{
		if (_user != null)
			_user.dispose();

		if (_environmentList != null)
			_environmentList.dispose();

		if (_versionList != null)
			_versionList.dispose();
	}

	UserViewModel _user;
	UserViewModel get user
	{
		if (_user == null)
			_user = new UserViewModel();

		return _user;
	}

	EnvironmentListViewModel _environmentList;
	EnvironmentListViewModel get environmentList
	{
		if (_environmentList == null)
			_environmentList = new EnvironmentListViewModel();

		return _environmentList;
	}

	ApplicationListViewModel _applicationList;
	ApplicationListViewModel get applicationList
	{
		if (_applicationList == null)
			_applicationList = new ApplicationListViewModel();

		return _applicationList;
	}

	VersionListViewModel _versionList;
	VersionListViewModel get versionList
	{
		if (_versionList == null)
			_versionList = new VersionListViewModel();

		return _versionList;
	}

	List<ViewModel> getChildViewModels()
	{
		return [_environmentList, _versionList];
	}

	String toString() => 'data view model';
}
