import 'dart:html';

import '../../MVVM/SubscriptionEvent.dart';
import '../../MVVM/View.dart';
import '../../MVVM/BoundTextInput.dart';

import '../../Events/AppEvents.dart';
import '../../ViewModels/MachineViewModel.dart';

class MachineEditView extends View
{
	BoundTextInput<String> _nameBinding;

	MachineEditView([MachineViewModel viewModel])
	{
		_nameBinding = new BoundTextInput<String>(addInput(classNames: ['machine-name', 'input-field']));
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