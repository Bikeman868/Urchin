import '../DataBinding/ChangeState.dart';

abstract class ViewModel
{
	ChangeState state;

    void dispose()
    {
    }

	void deleted()
	{
		if (state == ChangeState.added)
			state = ChangeState.unmodified;
		else if (state == ChangeState.unmodified)
			state = ChangeState.deleted;
	}

	void modified()
	{
		if (state == ChangeState.unmodified)
			state = ChangeState.modified;
	}

	void saved()
	{
		state = ChangeState.unmodified;
	}

	ChangeState getState()
	{
		return state;
	}
}