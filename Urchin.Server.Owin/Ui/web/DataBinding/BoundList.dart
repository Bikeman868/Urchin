import 'dart:html';
import 'dart:async';

import '../Html/HtmlBuilder.dart';

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
		if (value != null)
			value.classes.add('boundList');
        _listContainer = value;

        if (_binding != null)
            _constructViews();
    }
  
    void _constructViews()
    {
        if (_listContainer == null) return;
		var builder = new HtmlBuilder();
        if (_binding != null && _binding.viewModels != null)
        {
            for (var index = 0; index < _binding.viewModels.length; index++)
            {
                var listItem = builder.addContainer(className:'boundListElement');

                var viewContainer = builder.addContainer(className:'boundListView', parent: listItem);
                var view = viewFactory(_binding.viewModels[index]);
                view.addTo(viewContainer);

				if (allowRemove)
				{
					var deleteButton = builder.addImage('ui/images/delete{_v_}.gif', altText: 'Delete', classNames: ['boundListDelete','imageButton'], parent: listItem, onClick: _deleteClicked)
						..attributes['listIndex'] = index.toString();
				}
            }
			if (allowAdd)
			{
				var addButton = builder.addImage('ui/images/add{_v_}.gif', altText: 'New', classNames: ['boundListAdd','imageButton'], onClick: _addClicked);
			}
        }
		builder.displayIn(_listContainer);
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
