import 'ChangeState.dart';

abstract class ViewModel
{
	ChangeState state;

	ViewModel()
	{
		state = ChangeState.added;
	}

	void dispose()
	{
	}

	// Indicates that the view model should be deleted whan changes are saved back to the server
	void deleted()
	{
		if (state == ChangeState.added)
			state = ChangeState.unmodified;
		else if (state == ChangeState.unmodified)
			state = ChangeState.deleted;
	}

	// Indicates that the view model has changes that need to be persisted to the server
	void modified()
	{
		if (state == ChangeState.unmodified)
			state = ChangeState.modified;
	}

	// Indicates that this is a new record that does not exist on the server
	void added()
	{
		state = ChangeState.added;
	}

	// Indicates that all changes have been saved to the server
	void saved()
	{
		if (state != ChangeState.deleted)
		{
			state = ChangeState.unmodified;

			List<ViewModel> children = getChildViewModels();
			if (children != null)
			{
				for (ViewModel child in children)
				{
					child.saved();
				}
			}
		}
	}

	// Indicates that the underlying models were populated from the server and any pending changes should be ignored
	void loaded()
	{
		state = ChangeState.unmodified;

		List<ViewModel> children = getChildViewModels();
		if (children != null)
		{
			for (ViewModel child in children)
			{
				child.loaded();
			}
		}
	}

	// Gets the current state of this view model
	ChangeState getState()
	{
		if (state != ChangeState.unmodified)
			return state;

		List<ViewModel> children = getChildViewModels();
		if (children != null)
		{
			for (ViewModel child in children)
			{
				if (child.getState() != ChangeState.unmodified)
					return ChangeState.modified;
			}
		}

		return ChangeState.unmodified;
	}

	// Override this in derrived classes to provide a list of other view models
	// that come into play when figuring out the change state of this view model
	List<ViewModel> getChildViewModels()
	{
		return null;
	}
}