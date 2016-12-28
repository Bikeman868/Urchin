import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundLabel.dart';
import '../../MVVM/Events.dart';

import '../../Events/AppEvents.dart';
import '../../ViewModels/EnvironmentViewModel.dart';

class EnvironmentNameView extends View
{
	BoundLabel<String> _nameBinding;

	EnvironmentNameView([EnvironmentViewModel viewModel])
	{
		_nameBinding = new BoundLabel<String>(
			addSpan(className: 'environment-name'), 
			formatMethod: (s) => s + ' ');

		this.viewModel = viewModel;
	}

	EnvironmentViewModel _viewModel;
	EnvironmentViewModel get viewModel => _viewModel;

	void set viewModel(EnvironmentViewModel value)
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