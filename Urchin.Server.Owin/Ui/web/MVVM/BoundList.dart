import 'dart:html';
import 'HtmlBuilder.dart';
import 'View.dart';
import 'Model.dart';
import 'ViewModel.dart';
import 'Types.dart';
import 'BoundContainer.dart';

// Provides tw-way binding of a list of view models to a list of views
// * Generates <li> elements and adds them to the list container
// * Wraps each view in a container that provides a list selection mechanism
// * Can optionally display add/remove buttons to manage the list

class BoundList<TM extends Model, TVM extends ViewModel, TV extends View> extends BoundContainer
{
    BoundList(
		ViewFactory<TVM, TV> viewFactory, 
		Element listContainer,
		{
			ViewModelMethod<TVM> selectionMethod : null,
			this.allowAdd : true,
			this.allowRemove : true
		}) 
		: super(viewFactory, listContainer, selectionMethod: selectionMethod)
    {
	}
  
	bool allowAdd;
	bool allowRemove;

    void initializeContainer(Element container)
    {
		container.classes.add('bound-list');
		if (selectionMethod != null)
			container.classes.add('selection-list');
    }
  
    void refresh()
    {
        if (container == null) return;

		var builder = new HtmlBuilder();

        if (binding != null && binding.viewModels != null)
        {
            for (var index = 0; index < binding.viewModels.length; index++)
            {
                var listItem = builder.addListElement(className:'bound-list-item');
				if (selectionMethod != null)
				{
					listItem.attributes['index'] = index.toString();
					listItem.onClick.listen(itemClicked);
				};

				var viewContainer = builder.addContainer(className:'bound-list-view', parent: listItem);
				var view = viewFactory(binding.viewModels[index]);
				view.addTo(viewContainer);

				if (allowRemove)
				{
					var deleteButton = builder.addImage(
						'ui/images/delete{_v_}.gif',
						altText: 'Delete',
						classNames: ['bound-list-delete','image-button'],
						parent: listItem,
						onClick: _deleteClicked)
					..attributes['index'] = index.toString();
				}
            }

			if (allowAdd)
			{
				var listItem = builder.addListElement(className:'list-item');
				var viewContainer = builder.addContainer(className:'list-view', parent: listItem);
				var addButton = builder.addImage(
					'ui/images/add{_v_}.gif',
					altText: 'New',
					classNames: ['bound-list-add','image-button'],
					parent: listItem,
					onClick: _addClicked);
			}
        }

		builder.displayIn(container);
    }
  
    void _deleteClicked(MouseEvent e)
    {
		if (binding != null)
		{
			ButtonElement button = e.target;
			int index = int.parse(button.attributes['index']);
			binding.remove(index);
		}
    }
  
    void _addClicked(MouseEvent e)
    {
		if (binding != null)
		{
			binding.add();
		}
    }
}
