import '../Events/SubscriptionEvent.dart';
import '../DataBinding/Types.dart';
import '../DataBinding/ViewModel.dart';

// Provides two-way data binding to a list of models
// The binding is associated with a single list of models
// and many UI list elements. A view model is basically a collection
// of these PropertyBinding<T> and ListBinding<T> objects that connect the 
// views to the models.
class ListBinding<TM, TVM extends ViewModel>
{
	ModelFactory<TM> modelFactory;
	ViewModelFactory<TM, TVM> viewModelFactory;
  
	SubscriptionEvent<ListEvent> onAdd = new SubscriptionEvent<ListEvent>();
	SubscriptionEvent<ListEvent> onRemove = new SubscriptionEvent<ListEvent>();
  
	List<TVM> viewModels;

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
	}
  
	ListBinding(this.modelFactory, this.viewModelFactory, [List<TM> models])
	{
		viewModels = new List<TVM>();
		this.models = models;
	}
  
	void add()
	{
		int index = models.length;
      
		TM model = modelFactory();
		models.add(model);
      
		TVM viewModel = viewModelFactory(model);
		viewModels.add(viewModel);
      
		onAdd.raise(new ListEvent(index));
	}
  
	void remove(int index)
	{
		TVM viewModel = viewModels[index];
		TM model = models[index];
      
		onRemove.raise(new ListEvent(index));
      
		viewModels.removeAt(index);
		models.removeAt(index);
      
		viewModel.dispose();
	}
}

class ListEvent
{
  int index;
  ListEvent(this.index);
}
