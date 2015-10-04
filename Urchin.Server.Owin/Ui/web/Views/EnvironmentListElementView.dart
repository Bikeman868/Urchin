import 'dart:html';

import '../Events/SubscriptionEvent.dart';
import '../Events/AppEvents.dart';
import '../DataBinding/Binding.dart';
import '../DataBinding/BoundLabel.dart';
import '../Models/EnvironmentModel.dart';
import '../ViewModels/EnvironmentViewModel.dart';

class EnvironmentListElementView
{
	LIElement name;
	BoundLabel _nameBinding;
	SubscriptionEvent<EnvironmentSelectedEvent> environmentSelected = new SubscriptionEvent<EnvironmentSelectedEvent>();

	EnvironmentListElementView([EnvironmentViewModel viewModel])
	{
		name = new LIElement();
		name.classes.add('environmentName');
		name.classes.add('selectionItem');
		name.onClick.listen(_environmentClicked);

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

	void _environmentClicked(MouseEvent e)
	{
		environmentSelected.raise(new EnvironmentSelectedEvent(_viewModel));
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