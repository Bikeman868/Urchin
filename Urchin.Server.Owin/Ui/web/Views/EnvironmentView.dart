impoer 'dart:html';
import '../DataBinding/Binding.dart';
import '../Models/EnvironmentDto.dart';
import '../ViewModels/EnvironmentViewModel.dart';

class EnvironmentView
{
	SpanElement name;
	BoundLabel _nameBinding;

	SpanElement version;
	BoundLabel _versionBinding;

	EnvironmentView()
	{
		name = new SpanElement();
		version = new SpanElement();

		_nameBinding = new BoundLabel(name);
		_versionBinding = new BoundLabel(version);
	}

	void bind(EnvironmentViewModel viewModel)
	{
		_nameBinding.binding = viewModel.name;
		_versionBinding.binding = viewModel.version;
	}
}