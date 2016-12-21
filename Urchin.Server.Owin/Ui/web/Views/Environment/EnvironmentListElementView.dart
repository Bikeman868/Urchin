import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundLabel.dart';
import '../../MVVM/SubscriptionEvent.dart';

import '../../Events/AppEvents.dart';
import '../../ViewModels/EnvironmentViewModel.dart';

class EnvironmentListElementView extends View
{
	Element name;
	BoundLabel _nameBinding;

	EnvironmentListElementView([EnvironmentViewModel viewModel])
	{
		name = new DivElement()
			..classes.add('environment-name')
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