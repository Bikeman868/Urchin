import 'dart:html';
import 'dart:async';
import 'BoundElement.dart';
import 'SubscriptionEvent.dart';

class BoundIFrame<T> extends BoundElement<T, IFrameElement>
{
	BoundIFrame (IFrameElement element)
	{
		this.element = element;
	}
	
	void onBindingChange(String src)
	{
		if (element != null)
		{
			if (src == null)
				element.src = '';
			else
				element.src = src;
		}
	}

	StreamSubscription<Event> subscribeToElement(IFrameElement iframe)
	{
		return null;
	}
}

