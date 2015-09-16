import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../Dto.dart';
import '../Data.dart';
import '../ApplicationEvents.dart';

class VersionListComponent
{
	Data _data;

	VersionListComponent(this._data)
	{
	}
  
	void displayIn(containerDiv) async
	{
		var heading = new SpanElement();
		heading.classes.add('panelTitle');
		heading.text = 'Versions';
		containerDiv.children.add(heading);

		Map<String, VersionDto> versions = await _data.getVersions();
		if (versions != null)
		{
			var list = new UListElement();
			list.classes.add("selectionList");
			for (VersionDto version in versions)
			{
				var element = new LIElement();
				element.text = version.version.toString() + ' - ' + version.name;
				element.classes.add('versionName');
				element.classes.add('selectionItem');
				element.attributes['version'] = version.version.toString();
				element.onClick.listen(versionClicked);
				list.children.add(element);
			}
			containerDiv.children.add(list);
		}
	}

	void versionClicked(MouseEvent e)
	{
		LIElement target = e.target;
		var version = int.parse(target.attributes['version']);
		ApplicationEvents.versionSelected(version);
	}
}
