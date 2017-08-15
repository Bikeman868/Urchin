import '../../MVVM/Mvvm.dart';
import '../../ViewModels/ApplicationViewModel.dart';

class ApplicationNameView extends View
{
	BoundLabel<String> _nameBinding;

	ApplicationNameView([ApplicationViewModel viewModel])
	{
		_nameBinding = new BoundLabel<String>(
			addSpan(className: 'application-name'), 
			formatMethod: (s) => s + ' ');

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