import '../../MVVM/Mvvm.dart';

import '../../ViewModels/ApplicationViewModel.dart';

class ApplicationDisplayView extends View
{
	BoundLabel<String> _nameBinding;

	ApplicationDisplayView([ApplicationViewModel viewModel])
	{
		_nameBinding = new BoundLabel<String>(
			addHeading(2, 'Application Details'), 
			formatMethod: (s) => s + ' Application');

		this.viewModel = viewModel;
	}

	ApplicationViewModel _viewModel;
	ApplicationViewModel get viewModel => _viewModel;

	void set viewModel(ApplicationViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_nameBinding.binding = null;
		}
		else
		{
			_nameBinding.binding = value.name;
		}
	}
}