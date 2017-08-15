import '../../MVVM/Mvvm.dart';

import '../../ViewModels/DatacenterViewModel.dart';

class DatacenterEditView extends View
{
	BoundTextInput<String> _nameBinding;
	BoundLabel<String> _titleBinding;

	DatacenterEditView([DatacenterViewModel viewModel])
	{
		_titleBinding = new BoundLabel<String>(
			addHeading(2, 'Datacenter Details'), 
			formatMethod: (s) => 'Edit ' + s + ' Datacenter');

		addBlockText('A datacenter is a physical location where many servers are hosted.' +
			'<br>Defining datacenters allows you to create Urchin rules that will set certain' +
			'<br>configuration values for all software running in the datacenter.'
			, className: 'help-note');

		var form = addForm();
		_nameBinding = new BoundTextInput<String>(addLabeledEdit(form, 'Datacenter name'));

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
			_titleBinding.binding = null;
		}
		else
		{
			_nameBinding.binding = value.name;
			_titleBinding.binding = value.name;
		}
	}

}