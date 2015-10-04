import 'dart:html';
import '../DataBinding/Binding.dart';
import '../DataBinding/BoundLabel.dart';
import '../Models/EnvironmentModel.dart';
import '../ViewModels/EnvironmentViewModel.dart';

class EnvironmentListElementView
{
	LIElement name;
	BoundLabel _nameBinding;

	EnvironmentListElementView([EnvironmentViewModel viewModel])
	{
		name = new LIElement();
		name.classes.add('environmentName');
		name.classes.add('selectionItem');

		_nameBinding = new BoundLabel(name);

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