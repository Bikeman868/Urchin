import 'dart:async';

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
