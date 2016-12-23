import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundLabel.dart';

import '../../ViewModels/RuleViewModel.dart';

class RuleListElementView extends View
{
	BoundLabel<String> _nameBinding;

	RuleListElementView([RuleViewModel viewModel])
	{
		_nameBinding = new BoundLabel<String>(addSpan());

		this.viewModel = viewModel;
	}

	RuleViewModel _viewModel;
	RuleViewModel get viewModel => _viewModel;

	void set viewModel(RuleViewModel value)
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
