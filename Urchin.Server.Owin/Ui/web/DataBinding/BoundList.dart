import 'dart:html';
import 'dart:async';

import '../DataBinding/View.dart';
import '../DataBinding/ViewModel.dart';
import '../DataBinding/Types.dart';
import '../DataBinding/ListBinding.dart';

import '../Events/SubscriptionEvent.dart';


class BoundList<TM, TVM extends ViewModel, TV extends View>
{
    ListBinding<TM, TVM> _binding;
    ListBinding<TM, TVM> get binding => _binding;

    void set binding(ListBinding<TM, TVM> value)
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
            _constructViews();
            _addSubscription = value.onAdd.listen(_onAdd);      
            _removeSubscription = value.onAdd.listen(_onRemove);      
        }
    }
  
    StreamSubscription<ListEvent> _addSubscription;
    StreamSubscription<ListEvent> _removeSubscription;
    ViewFactory<TVM, TV> viewFactory;

    Element _listContainer;
    Element get listContainer => _listContainer;

    void set listContainer(Element value)
    {
        _listContainer = value;
        if (_binding != null)
            _constructViews();
    }
  
    void _constructViews()
    {
        if (_listContainer != null)
        {
            _listContainer.children.clear();
            if (_binding != null && _binding.viewModels != null)
            {
                for (var index = 0; index < _binding.viewModels.length; index++)
                {
                    var listItem = new DivElement();
                    _listContainer.children.add(listItem);

                    var viewContainer = new DivElement();
                    listItem.children.add(viewContainer);
                    var view = viewFactory(_binding.viewModels[index]);
                    view.addTo(viewContainer);

                    var deleteButton = new ButtonElement()
                        ..text = 'Delete'
                        ..onClick.listen(_deleteClicked);
                    listItem.children.add(deleteButton);
                }
            }
        }
    }
  
    BoundList(this.viewFactory, Element listContainer)
    {
        this.listContainer = listContainer;
    }
  
    void _deleteClicked(MouseEvent e)
    {
    }
  
    void _onAdd(ListEvent e)
    {
    }
  
    void _onRemove(ListEvent e)
    {
    }
}
