﻿import 'dart:html';

import '../../MVVM/SubscriptionEvent.dart';
import '../../MVVM/View.dart';
import '../../MVVM/BoundLabel.dart';

import '../../Events/AppEvents.dart';
import '../../ViewModels/MachineViewModel.dart';

class MachineListElementView extends View
{
	BoundLabel<String> _nameBinding;

	MachineListElementView([MachineViewModel viewModel])
	{
		_nameBinding = new BoundLabel<String>(addDiv(className: 'machine-name'));
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