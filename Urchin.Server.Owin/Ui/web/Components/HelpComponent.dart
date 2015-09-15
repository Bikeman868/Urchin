import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../Html/HtmlBuilder.dart';
import '../ApplicationEvents.dart';

class HelpComponent
{
	HtmlBuilder _html;

	Element _heading;
	Element _paragraphs;

	StreamSubscription<TabChangedEvent> _onTabChangedSubscription;

	HelpComponent()
	{
		_html = new HtmlBuilder();

		_heading = _html.addHeading(2, "Instructions");
		_paragraphs = _html.addContainer();

		_displayRulesInstructions();
		_onTabChangedSubscription = ApplicationEvents.onTabChanged.listen(_tabChanged);
	}
  
	void dispose()
	{
		_onTabChangedSubscription.cancel();
		_onTabChangedSubscription = null;
	}
  
	void displayIn(containerDiv)
	{
		_html.addTo(containerDiv);
	}

	void _tabChanged(TabChangedEvent e)
	{
		_heading.text = 'About ' + e.tabName;

		if (e.tabName == 'Rules') _displayRulesInstructions();
		if (e.tabName == 'Environments') _displayEnvironmentsInstructions();
		if (e.tabName == 'Test Query') _displayTestQueryInstructions();
		if (e.tabName == 'Versions') _displayVersionsInstructions();
	}

	void _displayRulesInstructions()
	{
		var builder = new HtmlBuilder();

		builder.addBlockText(
			'Rules are listed on this page in the order they will be evaluated. Less '
			'specific rules are evaluated first so that more specific rules will override '
			'more generic ones. When rules are equally specific, instance rules override '
			'machine rules, which override application rules, which override environment '
			'rules.',
			className: 'instruction');

		builder.addBlockText(
			'When a request for configuration is received, the Urchin server will evaluate '
			'the matching rules twice. On the first pass it will make a list of all the variables '
			'and their values, with more specific rules overriding less specific ones. On '
			'the second pass it will substitute variable references with their values and merge the '
			'configuration JSON. Note that the configuration JSON does not have to be valid '
			'when it contains variable references, but must be valid after the varibale values '
			'are substituted',
			className: 'instruction');

		builder.addBlockText(
			'The following variables are pre-defined and can be used in any rules: '
			r'($machine$) ($instance$) ($application$) and ($environment$).', 
			className: 'instruction');

		builder.addBlockText(
			'In this release variables can not be defined in terms of other variables ',
			className: 'instruction');

		builder.displayIn(_paragraphs);
	}

	void _displayEnvironmentsInstructions()
	{
		var builder = new HtmlBuilder();

		builder.addBlockText(
			'An environment defines a collection of machines that have the same '
			'security restrictions, and have shared configuration because of how '
			'they connect to the rest of the system.', 
			className: 'instruction');
			
		builder.addBlockText(
			'Machines in the same environment '
			'will typically have the same database connection strings, the same '
			'URLs to other services and the same network file paths. Machines in'
			'different environments will typically have different values for these', 
			className: 'instruction');

		builder.addBlockText(
			'You can specify IP address restrictions for each environment. Only machines '
			'with an allowed IP address will be able to retrieve configuration data for '
			'that environment, this means that connection strings can contain passwords '
			'and they will not be accessible except on machines in the intended environment. '
			'You can bypass these IP restrictions by logging on with the administrator password.', 
			className: 'instruction');

		builder.displayIn(_paragraphs);
	}

	void _displayTestQueryInstructions()
	{
		var builder = new HtmlBuilder();

		builder.addBlockText(
			'Use this page to test the current configuration of a specific application '
			'running on a specific machine. This is useful if you just want to know how '
			'an application is currently configured.',
			className: 'instruction');

		builder.addBlockText(
			'Note that this request goes back to the server, so any changes you made on your '
			'browser will not be reflected in the results until you save your changes.', 
			className: 'instruction');

		builder.addBlockText(
			'Note that this request will use the version of the rules that are configured '
			'for the environment that the machine is in.', 
			className: 'instruction');

		builder.displayIn(_paragraphs);
	}

	void _displayVersionsInstructions()
	{
		var builder = new HtmlBuilder();

		builder.addBlockText(
			'Each environment can use a different version of the rules. This has many uses '
			'including:',
			className: 'instruction');

		var list = builder.addList();
		builder.addListElement('Testing rule changes as a new version before applying the rules to live instances.', list, className: 'instruction');
		builder.addListElement('Keeping the config in line with the code version as code moves through the deployment pipeline from development to integration etc and finally into production.', list, className: 'instruction');
		builder.addListElement('Deploying a new configuration with the ability to roll back if necessary.', list, className: 'instruction');
		builder.addListElement('Having different config for different situations, for example when the site is in maintenance mode, or part of the system is down for maintenance.', list, className: 'instruction');

		builder.addBlockText(
			'You don not have to use versions; you can leave all environments at version 1.',
			className: 'instruction');

		builder.displayIn(_paragraphs);
	}
}
