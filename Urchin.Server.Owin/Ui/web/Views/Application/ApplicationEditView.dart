import '../../MVVM/Mvvm.dart';

import '../../ViewModels/ApplicationViewModel.dart';

class ApplicationEditView extends View
{
	BoundTextInput<String> _nameBinding;
	BoundLabel<String> _titleBinding;

	ApplicationEditView([ApplicationViewModel viewModel])
	{
		_titleBinding = new BoundLabel<String>(
			addHeading(2, 'Application Details'), 
			formatMethod: (s) => 'Edit ' + s + ' Application');

		addBlockText('Unique application names must be hard coded into each application.' +
			'<br>When an application requests its configuration from Urchin it must include' +
			'<br>its unique application name in the query string of the URL.'
			, className: 'help-note');

		var form = addForm();
		_nameBinding = new BoundTextInput<String>(addLabeledEdit(form, 'Application name'));

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
			_titleBinding.binding = null;
		}
		else
		{
			_nameBinding.binding = value.name;
			_titleBinding.binding = value.name;
		}
	}

}