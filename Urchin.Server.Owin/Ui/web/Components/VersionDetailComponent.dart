import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../Html/FormBuilder.dart';
import '../Dto.dart';
import '../Data.dart';
import '../ApplicationEvents.dart';

class VersionDetailComponent
{
	Data _data;

	FormBuilder _form;

	Element _heading1;
	Element _heading2;
	Element _version;
	Element _name;
	Element _rules;

	StreamSubscription<VersionSelectedEvent> _onVersionSelectedSubscription;

	VersionDetailComponent(this._data)
	{
		_form = new FormBuilder();
		_heading1 = _form.addHeading('Version', 1);
		_version = _form.addLabeledField('Version number');
		_name = _form.addLabeledField('Version name');
		_heading2 = _form.addHeading('Rules in this version', 2);
		_rules = _form.addList('ruleList');

		_onVersionSelectedSubscription = ApplicationEvents.onVersionSelected.listen(_versionSelected);
	}
  
	void dispose()
	{
		_onVersionSelectedSubscription.cancel();
		_onVersionSelectedSubscription = null;
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
				var element = new LIElement();
				element.text = ruleName;
				element.classes.add('ruleName');
				element.classes.add('selectionItem');
				element.onClick.listen(_ruleClicked);
				_rules.children.add(element);
			}
		}
		ApplicationEvents.ruleSelected(versionNumber, null);
	}

	void _ruleClicked(MouseEvent e)
	{
		Element target = e.target;
		ApplicationEvents.ruleSelected(int.parse(_version.text), target.text);
	}
}