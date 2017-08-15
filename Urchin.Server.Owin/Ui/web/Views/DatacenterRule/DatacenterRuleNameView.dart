import '../../MVVM/Mvvm.dart';
import '../../ViewModels/DatacenterRuleViewModel.dart';

class DatacenterRuleNameView extends View
{
	BoundLabel<String> _nameBinding;

	DatacenterRuleNameView([DatacenterRuleViewModel viewModel])
	{
		_nameBinding = new BoundLabel<String>(
			addSpan(className: 'datacenter-rule-name'), 
			formatMethod: (s) => s + ' ');

		this.viewModel = viewModel;
	}

	DatacenterRuleViewModel _viewModel;
	DatacenterRuleViewModel get viewModel => _viewModel;

	void set viewModel(DatacenterRuleViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_nameBinding.binding = null;
		}
		else
		{
			_nameBinding.binding = value.datacenter;
		}
	}
}