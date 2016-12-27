import 'dart:html';
import 'dart:async';

import 'HtmlBuilder.dart';
import 'View.dart';
import 'Model.dart';
import 'ViewModel.dart';
import 'Types.dart';
import 'ModelListBinding.dart';

import 'SubscriptionEvent.dart';
import 'ListEvent.dart';

// Abstract base class for components that bind to a list of view models.
// * Subscribes to events from add/remove actions when bound to a list
// * Refreshes the list UI when items are added or removed from the list
// * Unsubscribes from add/remove events when unbound 
// * When items in the list are selected, identifies the element and calls the selection method

abstract class BoundContainer<TM extends Model, TVM extends ViewModel, TV extends View>
{
    BoundContainer(
		this.viewFactory,
		Element container, 
		{
			this.selectionMethod : null
		})
    {
        this.container = container;
    }
  
    ModelListBinding<TM, TVM> _binding;
    ModelListBinding<TM, TVM> get binding => _binding;

    void set binding(ModelListBinding<TM, TVM> value)
    {
        if (_addSubscription != null)
        {
            _addSubscription.cancel();
            _addSubscription = null;
        }
        if (_removeSubscription != null)
        {
            _removeSubscription.cancel();
            _removeSubscription = null;
        }

        _binding = value;

        if (value != null)
        {
            refresh();
            _addSubscription = value.onAdd.listen(_onAdd);      
            _removeSubscription = value.onRemove.listen(_onRemove);      
        }
    }
  
    StreamSubscription<ListEvent> _addSubscription;
    StreamSubscription<ListEvent> _removeSubscription;
    ViewFactory<TVM, TV> viewFactory;
	ViewModelMethod<TVM> selectionMethod;

    Element _container;
    Element get container => _container;
	void set container(Element value) 
	{
		_container = value;
		initializeContainer(value);
		refresh();
	}

    void initializeContainer(Element value);
    void refresh();
  
	void itemClicked(MouseEvent e)
	{
		if (selectionMethod == null) return;
		if (_binding == null) return;

		Element element = e.target;
		while (element != null)
		{
			var indexAttribute = element.attributes['index'];
			if (indexAttribute != null)
			{
				int index = int.parse(indexAttribute);
				var viewModel = _binding.viewModels[index];
				if (viewModel != null)
					selectionMethod(viewModel);
				return;
			}
			element = element.parent;
		}
	}

    void _onAdd(ListEvent e)
    {
		refresh();
    }
  
    void _onRemove(ListEvent e)
    {
		refresh();
    }
}
