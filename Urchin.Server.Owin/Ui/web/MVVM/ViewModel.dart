import 'dart:html';
import 'dart:async';

import 'Enums.dart';
import 'ModelListBinding.dart';

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

	// Saves this view model back to the server.
	// Changes it's state back to unmodified unless it is deleted
	bool _saving;
	Future<SaveResult> save([bool alert = true]) async
	{
		if (_saving) return SaveResult.notsaved;
		_saving = true;

		try
		{
			var state = getState();

			if (state == ChangeState.unmodified)
				return SaveResult.unmodified;

			var result = await saveChanges(state, alert);

			if (result == SaveResult.saved)
				saved();

			_saving = false;
			return result;
		}
		catch (e)
		{
			window.alert(e.toString());

			_saving = false;
			return SaveResult.failed;
		}
	}

	// Override in derrived classes to save changes in this view model back to the server
	// The default behaviour in this base class is to save all the child view models
	Future<SaveResult> saveChanges(ChangeState state, bool alert) async
	{
		SaveResult result = SaveResult.saved;

		List<ModelListBinding> modelLists = getModelLists();
		if (modelLists != null)
		{
			for (ModelListBinding modelList in modelLists)
			{
				for (ViewModel viewModel in modelList.viewModels)
				{
					var viewModelResult = await viewModel.save(false);
					if (viewModelResult == SaveResult.failed)
						result = SaveResult.failed;
				}
			}
		}

		List<ViewModel> children = getChildViewModels();
		if (children != null)
		{
			for (ViewModel child in children)
			{
				var childResult = await child.save(false);
				if (childResult == SaveResult.failed)
					result = SaveResult.failed;
			}
		}

		return result;
	}

	// Indicates that all changes have been saved to the server
	void saved()
	{
		if (state != ChangeState.deleted)
		{
			List<ModelListBinding> modelLists = getModelLists();
			if (modelLists != null)
			{
				for (ModelListBinding modelList in modelLists)
				{
					modelList.saved();
				}
			}

			List<ViewModel> children = getChildViewModels();
			if (children != null)
			{
				for (ViewModel child in children)
				{
					child.saved();
				}
			}

			state = ChangeState.unmodified;
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

	// Gets the current state of this view model and all of its children
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

		List<ModelListBinding> modelLists = getModelLists();
		if (modelLists != null)
		{
			for (ModelListBinding modelList in modelLists)
			{
				if (modelList.getState() != ChangeState.unmodified)
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

	// Override this in derrived classes to provide a list of the bound lists
	// of child models that are managed by this view model. This will ensure that
	// the change status of these view model lists will be maintained.
	List<ModelListBinding> getModelLists()
	{
		return null;
	}
}