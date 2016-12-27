import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundLabel.dart';

import '../../ViewModels/VersionViewModel.dart';

class VersionListElementView extends View
{
	BoundLabel<int> _versionBinding;
	BoundLabel<String> _nameBinding;

	VersionListElementView([VersionViewModel viewModel])
	{
		_versionBinding = new BoundLabel<int>(
			addSpan(), 
			formatMethod: (s) => s + ' - ');

		_nameBinding = new BoundLabel<String>(addSpan());

		this.viewModel = viewModel;
	}

	VersionViewModel _viewModel;
	VersionViewModel get viewModel => _viewModel;

	void set viewModel(VersionViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_versionBinding.binding = null;
			_nameBinding.binding = null;
		}
		else
		{
			_versionBinding.binding = value.version;
			_nameBinding.binding = value.name;
		}
	}
}
