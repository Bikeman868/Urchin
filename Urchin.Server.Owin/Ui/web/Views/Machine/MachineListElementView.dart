import 'dart:html';

import '../../MVVM/SubscriptionEvent.dart';
import '../../MVVM/View.dart';
import '../../MVVM/BoundLabel.dart';
import '../../MVVM/BoundTextInput.dart';

import '../../Events/AppEvents.dart';
import '../../Models/MachineModel.dart';
import '../../ViewModels/MachineViewModel.dart';

class MachineListElementView extends View
{
	InputElement name;
	BoundTextInput _nameBinding;

	MachineListElementView([MachineViewModel viewModel])
	{
		name = addInput(classNames: ['machine-name', 'input-field']);

		_nameBinding = new BoundTextInput(name);

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