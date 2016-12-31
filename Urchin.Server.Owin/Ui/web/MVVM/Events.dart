import 'dart:async';


// This is used to notify subscribers when items are added and removed from lists
class ListEvent
{
  int index;
  ListEvent(this.index);
}

// An event broadcaster. When events are raised they are sent to all listeners
class SubscriptionEvent<E>
{
	StreamController<E> _controller = new StreamController.broadcast();
  
	raise(E e)
	{
		_controller.add(e);
	}

	StreamSubscription<E> listen(void handler(E e)) 
	{
		return _controller.stream.listen(handler);
	}
}
