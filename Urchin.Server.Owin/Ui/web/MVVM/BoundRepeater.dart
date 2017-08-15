part of mvvm;

// Repeats a view for each item on the bound list without adding any additional markup

class BoundRepeater<TM extends Model, TVM extends ViewModel, TV extends View> extends BoundContainer
{

    BoundRepeater(
		ViewFactory<TVM, TV> viewFactory,
		Element container,
		{
			this.viewModelFilter : null,
			this.showDeleted : false
		}) 
		: super(viewFactory, container)
    {
    }
 
    void initializeContainer(Element container)
    {
    }

	Filter<TVM> viewModelFilter;
	bool showDeleted;
  
    void refresh()
    {
        if (container == null) return;

		container.children.clear();

        if (binding != null && binding.viewModels != null)
        {
            for (var viewModel in binding.viewModels)
            {
				if ((showDeleted || viewModel.getState() != ChangeState.deleted) && 
					(viewModelFilter == null || viewModelFilter(viewModel)))
					viewFactory(viewModel).addTo(container);
            }
        }
    }
}
