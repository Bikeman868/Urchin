import 'dart:html';

import '../../MVVM/Mvvm.dart';

import '../../ViewModels/RuleViewModel.dart';

class RuleNameView extends View
{
	BoundLabel<String> _nameBinding;

	RuleNameView([RuleViewModel viewModel])
	{
		_nameBinding = new BoundLabel<String>(
			addSpan(),
			formatMethod: (s) => s + ' ');

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
