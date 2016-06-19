import 'dart:html';

import '../Events/SubscriptionEvent.dart';
import '../Events/AppEvents.dart';

import '../DataBinding/View.dart';
import '../DataBinding/BoundLabel.dart';
import '../DataBinding/BoundTextInput.dart';

import '../Models/MachineModel.dart';

import '../ViewModels/MachineViewModel.dart';

class MachineListElementView extends View
{
	InputElement name;
	BoundTextInput _nameBinding;

	MachineListElementView([MachineViewModel viewModel])
	{
		name = new InputElement()
			..classes.add('machineName')
			..classes.add('inputField');

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

	void addTo(Element container)
	{
		container.children.add(name);
	}

	void displayIn(Element container)
	{
		container.children.clear();
		addTo(container);
	}
}