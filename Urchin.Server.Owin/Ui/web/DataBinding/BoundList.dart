import 'dart:html';
import 'dart:async';

import '../DataBinding/View.dart';
import '../DataBinding/Model.dart';
import '../DataBinding/ViewModel.dart';
import '../DataBinding/Types.dart';
import '../DataBinding/ListBinding.dart';

import '../Events/SubscriptionEvent.dart';


class BoundList<TM extends Model, TVM extends ViewModel, TV extends View>
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
            _removeSubscription = value.onRemove.listen(_onRemove);      
        }
    }
  
    StreamSubscription<ListEvent> _addSubscription;
    StreamSubscription<ListEvent> _removeSubscription;
    ViewFactory<TVM, TV> viewFactory;
	bool allowAdd;
	bool allowRemove;

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
			_listContainer.classes.add('boundList');
            _listContainer.children.clear();
            if (_binding != null && _binding.viewModels != null)
            {
                for (var index = 0; index < _binding.viewModels.length; index++)
                {
                    var listItem = new DivElement()
						..classes.add('boundListElement');
                    _listContainer.children.add(listItem);

                    var viewContainer = new DivElement();
					viewContainer.classes.add('boundListView');
                    listItem.children.add(viewContainer);
                    var view = viewFactory(_binding.viewModels[index]);
                    view.addTo(viewContainer);

					if (allowRemove)
					{
						var deleteButton = new ButtonElement()
							..text = 'Delete'
							..classes.add('boundListDelete')
							..attributes['listIndex'] = index.toString()
							..onClick.listen(_deleteClicked);
						listItem.children.add(deleteButton);
					}
                }
				if (allowAdd)
				{
					var addButton = new ButtonElement()
						..text = 'New'
						..classes.add('boundListAdd')
						..onClick.listen(_addClicked);
					_listContainer.children.add(addButton);
				}
            }
        }
    }
  
    BoundList(this.viewFactory, Element listContainer, [this.allowAdd = true, this.allowRemove = true])
    {
        this.listContainer = listContainer;
    }
  
    void _deleteClicked(MouseEvent e)
    {
		if (_binding != null)
		{
			ButtonElement button = e.target;
			int index = int.parse(button.attributes['listIndex']);
			_binding.remove(index);
		}
    }
  
    void _addClicked(MouseEvent e)
    {
		if (_binding != null)
		{
			_binding.add();
		}
    }
  
    void _onAdd(ListEvent e)
    {
		_constructViews();
    }
  
    void _onRemove(ListEvent e)
    {
		_constructViews();
    }
}
