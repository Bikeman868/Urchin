import 'dart:html';
import '../DataBinding/Binding.dart';
import '../DataBinding/BoundLabel.dart';
import '../DataBinding/BoundTextInput.dart';
import '../Models/EnvironmentModel.dart';
import '../ViewModels/EnvironmentViewModel.dart';
import '../ViewModels/MachineListViewModel.dart';
import '../Views/MachineListElementView.dart';

class MachineListView
{
	UListElement _machineList;

	MachineListView([MachineListViewModel viewModel])
	{
		_machineList = new UListElement();

		this.viewModel = viewModel;
	}

	MachineListViewModel _viewModel;
	MachineListViewModel get viewModel => _viewModel;
	void set viewModel(MachineListViewModel value)
	{
		_viewModel = value;
		_machineList.children.clear();
		if (value != null)
		{
			for (var machineViewModel in value.machines)
			{
				var view = new MachineListElementView(machineViewModel);
				view.addTo(_machineList);
			}
		}
	}

	void addTo(Element container)
	{
		container.children.add(_machineList);
	}

	void displayIn(Element container)
	{
		container.children.clear();
		addTo(container);
	}
}