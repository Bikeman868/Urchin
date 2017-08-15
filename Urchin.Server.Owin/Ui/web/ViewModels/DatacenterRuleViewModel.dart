import '../MVVM/Mvvm.dart';
import '../Models/DatacenterRuleModel.dart';

class DatacenterRuleViewModel extends ViewModel
{
    StringBinding machine = new StringBinding();
    StringBinding application = new StringBinding();
    StringBinding environment = new StringBinding();
    StringBinding instance = new StringBinding();
    StringBinding datacenter = new StringBinding();

	DatacenterRuleViewModel([DatacenterRuleModel model])
	{
		machine = new StringBinding();
		application = new StringBinding();
		environment = new StringBinding();
		instance = new StringBinding();
		datacenter = new StringBinding();

		this.model = model;
	}

	dispose()
	{
		model = null;
	}

	int version;

	DatacenterRuleModel _model;
	DatacenterRuleModel get model	=> _model; 

	void set model(DatacenterRuleModel value)
	{
		_model = value;

		if (value == null)
		{
			machine.setter = null;
			machine.getter = null;

			application.setter = null;
			application.getter = null;

			environment.setter = null;
			environment.getter = null;

			instance.setter = null;
			instance.getter = null;

			datacenter.setter = null;
			datacenter.getter = null;
		}
		else
		{
			machine.setter = (String text) 
			{ 
				value.machine = text;
				modified();
			};
			machine.getter = () => value.machine;

			application.setter = (String text) 
			{ 
				value.application = text;
				modified();
			};
			application.getter = () => value.application;

			environment.setter = (String text) 
			{ 
				value.environment = text;
				modified();
			};
			environment.getter = () => value.environment;

			instance.setter = (String text) 
			{ 
				value.instance = text;
				modified();
			};
			instance.getter = () => value.instance;

			datacenter.setter = (String text) 
			{ 
				value.datacenterName = text;
				modified();
			};
			datacenter.getter = () => value.datacenterName;
		}
		loaded();
	}

	String toString() => _model.toString() + ' view model';
}