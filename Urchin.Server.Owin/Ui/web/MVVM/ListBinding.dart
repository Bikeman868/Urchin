import 'SubscriptionEvent.dart';
import 'Types.dart';
import 'ViewModel.dart';
import 'Model.dart';
import 'ChangeState.dart';

// Provides two-way data binding to a list of models
// The binding is associated with a single list of models
// and many UI list elements. A view model is basically a collection
// of these PropertyBinding<T> and ListBinding<T> objects that connect the 
// views to the models.
class ListBinding<TM extends Model, TVM extends ViewModel>
{
	ModelFactory<TM> modelFactory;
	ViewModelFactory<TM, TVM> viewModelFactory;
  
	SubscriptionEvent<ListEvent> onAdd = new SubscriptionEvent<ListEvent>();
	SubscriptionEvent<ListEvent> onRemove = new SubscriptionEvent<ListEvent>();
  
	List<TVM> viewModels;
	bool _isModified;

	List<TM> _models;
	List<TM> get models => _models;

	void set models(List<TM> value)
	{
		for (int index = 0; index < viewModels.length; index++)
		{
			TVM viewModel = viewModels[index];
			onRemove.raise(new ListEvent(index));
			viewModel.dispose();
		}
		viewModels.clear();
      
		_models = value;

		if (value != null)
		{
			for (int index = 0; index < value.length; index++)
			{
				TVM viewModel = viewModelFactory(value[index]);
				viewModels.add(viewModel);
				onAdd.raise(new ListEvent(index));
			}
		}
		_isModified = false;
	}
  
	ListBinding(this.modelFactory, this.viewModelFactory, [List<TM> models])
	{
		viewModels = new List<TVM>();
		this.models = models;
	}
  
	void add()
	{
		int index = models.length;
      
		TM model = modelFactory(null);
		models.add(model);
      
		TVM viewModel = viewModelFactory(model);
		viewModels.add(viewModel);
      
		onAdd.raise(new ListEvent(index));
		_isModified = true;
	}
  
	void remove(int index)
	{
		TVM viewModel = viewModels[index];
		TM model = models[index];
      
		onRemove.raise(new ListEvent(index));
      
		viewModels.removeAt(index);
		models.removeAt(index);
      
		viewModel.dispose();

		_isModified = true;
	}

	ChangeState getState()
	{
		if (_isModified) return ChangeState.modified;
		for (TVM viewModel in viewModels)
		{
			var state = viewModel.getState();
			if (state != ChangeState.unmodified)
				return ChangeState.modified;
		}
		ChangeState.unmodified;
	}

}

class ListEvent
{
  int index;
  ListEvent(this.index);
}
