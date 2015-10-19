import 'dart:html';

import '../Events/SubscriptionEvent.dart';
import '../Events/AppEvents.dart';

import '../DataBinding/View.dart';
import '../DataBinding/BoundLabel.dart';

import '../ViewModels/EnvironmentViewModel.dart';

class EnvironmentListElementView extends View
{
	LIElement name;
	BoundLabel _nameBinding;

	EnvironmentListElementView([EnvironmentViewModel viewModel])
	{
		name = new LIElement()
			..classes.add('environmentName')
			..classes.add('selectionItem')
			..onClick.listen(_environmentClicked);

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
		AppEvents.environmentSelected.raise(new EnvironmentSelectedEvent(_viewModel));
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