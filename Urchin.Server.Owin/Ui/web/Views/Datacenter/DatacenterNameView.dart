import '../../MVVM/Mvvm.dart';
import '../../ViewModels/DatacenterViewModel.dart';

class DatacenterNameView extends View
{
	BoundLabel<String> _nameBinding;

	DatacenterNameView([DatacenterViewModel viewModel])
	{
		_nameBinding = new BoundLabel<String>(
			addSpan(className: 'datacenter-name'), 
			formatMethod: (s) => s + ' ');

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