import '../../MVVM/Mvvm.dart';
import '../../ViewModels/DatacenterRuleViewModel.dart';

class DatacenterRuleEditView extends View
{
	BoundTextInput<String> _instanceInput;
	BoundTextInput<String> _applicationInput;
	BoundTextInput<String> _machineInput;
	BoundTextInput<String> _environmentInput;
	BoundTextInput<String> _datacenterInput;

	DatacenterRuleEditView([DatacenterRuleViewModel viewModel])
	{
		addHeading(2, 'Datacenter Rule Details');

		addBlockText('Datacenter rules allow Urchin to figure out the datacenter from' +
			'<br>information supplied by the application (such as the machine name, application' +
			'<br>name and environment).'
			, className: 'help-note');

		addBlockText('Choose where to apply this rule. Leave boxes blank to apply to all.' +
			'<br>The save button will just save this specific version of this rule.', 
			className: 'help-note');

		var form1 = addForm();
		_instanceInput = new BoundTextInput<String>(addLabeledEdit(form1, 'Applies to instance', className: 'rule-instance'));
		_applicationInput = new BoundTextInput<String>(addLabeledEdit(form1, 'Applies to application', className: 'rule-application'));
		_machineInput = new BoundTextInput<String>(addLabeledEdit(form1, 'Applies to machine', className: 'rule-machine'));
		_environmentInput = new BoundTextInput<String>(addLabeledEdit(form1, 'Applies to environment', className: 'rule-environment'));

		addBlockText('Choose which datacenter to resolve to when this rule is matched.' +
			'<br>Note that when multiple rules match the most specific rule will apply.', 
			className: 'help-note');

		var form2 = addForm();
		_datacenterInput = new BoundTextInput<String>(addLabeledEdit(form2, 'Datacenter', className: 'rule-datacenter'));

		this.viewModel = viewModel;
	}

	DatacenterRuleViewModel _viewModel;
	DatacenterRuleViewModel get viewModel => _viewModel;

	void set viewModel(DatacenterRuleViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_instanceInput.binding = null;
			_applicationInput.binding = null;
			_machineInput.binding = null;
			_environmentInput.binding = null;
			_datacenterInput.binding = null;
		}
		else
		{
			_instanceInput.binding = value.instance;
			_applicationInput.binding = value.application;
			_machineInput.binding = value.machine;
			_environmentInput.binding = value.environment;
			_datacenterInput.binding = value.datacenter;
		}
	}
}