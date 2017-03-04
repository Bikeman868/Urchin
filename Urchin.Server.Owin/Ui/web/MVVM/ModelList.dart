import 'dart:async';

import 'Events.dart';
import 'Types.dart';
import 'ViewModel.dart';
import 'Model.dart';
import 'Enums.dart';
import 'Events.dart';

// Use this in your view models to maintain a list of models and the corresponding view models
// Many UI list elements can be bound to the list. They can add and remove models from the list
// and all views will be kept synchronized. When saving changes back to the server, the
// ModelList keeps track of deleted models so that they can be deleted from the server.
class ModelList<TM extends Model, TVM extends ViewModel>
{
	// Defines how to create new models
	ModelFactory<TM> modelFactory;
	
	// Defines how to create new view models
	ViewModelFactory<TM, TVM> viewModelFactory;

	// Defines how to update a view model with new data
	ViewModelUpdater<TM, TVM> viewModelUpdater;
  
	// Raised after a new model is added to the list
	SubscriptionEvent<ListEvent> onAdd = new SubscriptionEvent<ListEvent>();
	
	// Raised after a model is flagged for deletion. Most views should hide deleted view models
	SubscriptionEvent<ListEvent> onDelete = new SubscriptionEvent<ListEvent>();

	// Raised when the whole list of models is replaced with a new one
	SubscriptionEvent<ListEvent> onListChanged = new SubscriptionEvent<ListEvent>();
  
	// Contains a list of the view models. This list is maintained automatically
	List<TVM> _viewModels;
	List<TVM> get viewModels => _viewModels;

	// A reference to the list of models to maintain. This can be a property
	// from a model that contains a list of child models. When the user adds
	// and removes items in bound lists the model will be updated
	List<TM> _models;
	List<TM> get models => _models;

	ModelList(this.modelFactory, this.viewModelFactory, [List<TM> models, this.viewModelUpdater])
	{
		_viewModels = new List<TVM>();
		this.models = models;
	}

	void set models(List<TM> value)
	{
		_viewModels.forEach((TVM vm) => vm.dispose());
		_viewModels.clear();
      
		_models = value;

		if (_models != null)
			_models.forEach((TM m) => _viewModels.add(viewModelFactory(m)));

		onListChanged.raise(new ListEvent(-1));
	}

	void replaceModels(List<TM> models)
	{
		if (
			_models == null || 
			models == null || 
			_models.length != models.length ||
			viewModelUpdater == null)
		{
			this.models = models;
		}
		else
		{
			_models = models;
			for(var i = 0; i < models.length; i++)
			{
				viewModelUpdater(_viewModels[i], models[i]);
			}
		}
	}

	// Call this to indicate that the list of models was reloaded from the server
	void loaded()
	{
		models = _models;
	}
  
    // Call this to add a new model to the end of the list
	TVM add()
	{
		if (modelFactory == null)
			return null;

		return addModel(modelFactory(null));
	}

    // Call this to add a model to the end of the list
	TVM addModel(TM model)
	{
		if (_models == null)
			return null;

		int index = _models.length;

		_models.add(model);
      
		TVM viewModel = viewModelFactory(model);
		viewModel.added();
		_viewModels.add(viewModel);
      
		onAdd.raise(new ListEvent(index));

		return viewModel;
	}
  
	// Call this to mark a model for deletion upon save
	// The index positions don't change and view models can be un-deleted
	// before saving.
	void delete(int index)
	{
		TVM viewModel = _viewModels[index];

		if (viewModel.getState() == ChangeState.added)
		{
			_viewModels.removeAt(index);
			models.removeAt(index);
			viewModel.dispose();
			onListChanged.raise(new ListEvent(-1));
		}
		else
		{
			viewModel.deleted();
			onDelete.raise(new ListEvent(index));
		}
	}

	// Call this before saving changes to remove deleted models from the list
	void saving()
	{
		_viewModels.forEach((ViewModel vm) => vm.saving());
	}

	// Call this to make all the view models on this list save themselves back to the server
	Future<SaveResult> saveChanges() async
	{
		SaveResult result = SaveResult.saved;

		int index = 1;
		for (ViewModel vm in _viewModels)
		{
			index++;

			ChangeState vmState = vm.getState();
			SaveResult vmResult = await vm.saveChanges(vmState, false);
			if (vmResult == SaveResult.failed)
				result = vmResult;
		}

		return result;
	}

	// Call this to remove deleted models from the list. If your saving mechanism
	// serializes the parent and child models in one large JSON PUT then you should
	// remove deleted models before serializing the JSON. If your saving mechanism
	// is to send DELETE requests to the server then you should leave the deleted
	// modles in place until after the save is complete.
	void removeDeleted()
	{
		if (_models != null)
		{
			for (var index = _models.length - 1; index >= 0; index--)
			{
				var viewModel = _viewModels[index];
				if (viewModel.getState() == ChangeState.deleted)
				{
					models.removeAt(index);
					_viewModels.removeAt(index);
					viewModel.dispose();
				}
				else
				{
					viewModel.removeDeleted();
				}
			}
		}
	}

	// Call this ater saving changes to mark all the view models as saved
	void saved()
	{
		_viewModels.forEach((ViewModel vm) => vm.saved());
	}

	// Calculates the modification status of this list of models
	ChangeState getState()
	{
		for (TVM viewModel in _viewModels)
		{
			var state = viewModel.getState();
			if (state != ChangeState.unmodified)
				return ChangeState.modified;
		}
		return ChangeState.unmodified;
	}

}
