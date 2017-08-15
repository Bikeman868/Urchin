import '../../MVVM/Mvvm.dart';

import '../../ViewModels/DatacenterViewModel.dart';

class DatacenterDisplayView extends View
{
	BoundLabel<String> _nameBinding;

	DatacenterDisplayView([DatacenterViewModel viewModel])
	{
		_nameBinding = new BoundLabel<String>(
			addHeading(2, 'Datacenter Details'), 
			formatMethod: (s) => s + ' Datacenter');

		this.viewModel = viewModel;
	}

	DatacenterViewModel _viewModel;
	DatacenterViewModel get viewModel => _viewModel;

	void set viewModel(DatacenterViewModel value)
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