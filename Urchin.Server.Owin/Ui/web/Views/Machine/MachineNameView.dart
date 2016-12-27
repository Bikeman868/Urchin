import 'dart:html';

import '../../MVVM/SubscriptionEvent.dart';
import '../../MVVM/View.dart';
import '../../MVVM/BoundLabel.dart';

import '../../Events/AppEvents.dart';
import '../../ViewModels/MachineViewModel.dart';

class MachineNameView extends View
{
	BoundLabel<String> _nameBinding;

	MachineNameView([MachineViewModel viewModel])
	{
		_nameBinding = new BoundLabel<String>(
			addSpan(className: 'machine-name'),
			formatMethod: (s) => s + ' ');

		this.viewModel = viewModel;
	}

	MachineViewModel _viewModel;
	MachineViewModel get viewModel => _viewModel;

	void set viewModel(MachineViewModel value)
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