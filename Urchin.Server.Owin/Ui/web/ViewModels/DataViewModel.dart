import '../MVVM/Mvvm.dart';

import '../ViewModels/EnvironmentListViewModel.dart';
import '../ViewModels/VersionListViewModel.dart';
import '../ViewModels/ApplicationListViewModel.dart';
import '../ViewModels/DatacenterListViewModel.dart';
import '../ViewModels/DatacenterRuleListViewModel.dart';
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

	DatacenterListViewModel _datacenterList;
	DatacenterListViewModel get datacenterList
	{
		if (_datacenterList == null)
			_datacenterList = new DatacenterListViewModel();

		return _datacenterList;
	}

	DatacenterRuleListViewModel _datacenterRuleList;
	DatacenterRuleListViewModel get datacenterRuleList
	{
		if (_datacenterRuleList == null)
			_datacenterRuleList = new DatacenterRuleListViewModel();

		return _datacenterRuleList;
	}

	List<ViewModel> getChildViewModels()
	{
		return [_environmentList, _versionList, _applicationList];
	}

	String toString() => 'data view model';
}
