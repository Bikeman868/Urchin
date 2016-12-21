import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundLabel.dart';
import '../../MVVM/SubscriptionEvent.dart';

import '../../Events/AppEvents.dart';
import '../../ViewModels/EnvironmentViewModel.dart';

class EnvironmentListElementView extends View
{
	BoundLabel<String> _nameBinding;

	EnvironmentListElementView([EnvironmentViewModel viewModel])
	{
		_nameBinding = new BoundLabel<String>(addDiv(className: 'environment-name'));

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