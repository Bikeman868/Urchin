import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../Html/FormBuilder.dart';
import '../DataLayer/Data.dart';
import '../DataLayer/VersionData.dart';
import '../Events/AppEvents.dart';

class VersionDetailComponent
{
	Data _data;

	FormBuilder _form;

	Element _heading1;
	Element _heading2;
	Element _version;
	Element _name;
	Element _rules;

	StreamSubscription<VersionSelectedEvent> _versionSelectedSubscription;

	VersionDetailComponent(this._data)
	{
		_form = new FormBuilder();
		_heading1 = _form.addHeading('Version', 1);
		_version = _form.addLabeledField('Version number');
		_name = _form.addLabeledField('Version name');
		_heading2 = _form.addHeading('Rules in this version', 2);
		_rules = _form.addList('ruleList');

		_versionSelectedSubscription = AppEvents.versionSelected.listen(_versionSelected);
	}
  
	void dispose()
	{
		_versionSelectedSubscription.cancel();
		_versionSelectedSubscription = null;
	}

	void displayIn(containerDiv)
	{
		_form.addTo(containerDiv);
	}

	void _versionSelected(VersionSelectedEvent e) async
	{
		VersionData versionData = await _data.getVersion(e.version);
		var versionNumber = versionData.version.version;
		var versionName = versionData.version.name;

		_heading1.text = 'Version ' + versionNumber.toString();
		_heading2.text = 'Rules in ' + versionName;

		_version.text = versionNumber.toString();
		_name.text = versionName;

		_rules.children.clear();

		List<String> ruleNames = await versionData.getRuleNames();
		if (ruleNames != null)
		{
			for (String ruleName in ruleNames)
			{
				var element = new LIElement()
					..text = ruleName
					..classes.add('ruleName')
					..classes.add('selectionItem')
					..onClick.listen(_ruleClicked);
				_rules.children.add(element);
			}
		}
		AppEvents.ruleSelected.raise(new RuleSelectedEvent(versionNumber, null));
	}

	void _ruleClicked(MouseEvent e)
	{
		Element target = e.target;
		AppEvents.ruleSelected.raise(new RuleSelectedEvent(int.parse(_version.text), target.text));
	}
}
