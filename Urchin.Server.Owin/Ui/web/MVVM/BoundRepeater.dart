import 'dart:html';
import 'dart:async';

import 'HtmlBuilder.dart';
import 'View.dart';
import 'Model.dart';
import 'ViewModel.dart';
import 'BoundContainer.dart';
import 'Types.dart';

// Repeats a view for each item on the bound list without adding any additional markup

class BoundRepeater<TM extends Model, TVM extends ViewModel, TV extends View> extends BoundContainer
{

    BoundRepeater(
		ViewFactory<TVM, TV> viewFactory,
		Element container) 
		: super(viewFactory, container)
    {
    }
 
    void initializeContainer(Element container)
    {
    }
  
    void refresh()
    {
        if (container == null) return;

		    container.children.clear();

        if (binding != null && binding.viewModels != null)
        {
            for (var viewModel in binding.viewModels)
            {
                viewFactory(viewModel).addTo(container);
            }
        }
    }
}
