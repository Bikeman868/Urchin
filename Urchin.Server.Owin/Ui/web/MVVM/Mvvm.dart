library mvvm;

import 'dart:html';
import 'dart:async';

part 'Types.dart';
part 'Events.dart';
part 'HtmlBuilder.dart';

part 'Model.dart';
part 'View.dart';
part 'ViewModel.dart';

part 'ModelList.dart';
part 'PropertyBinding.dart';
part 'StringBinding.dart';
part 'IntBinding.dart';

part 'BoundContainer.dart';
part 'BoundElement.dart';
part 'BoundFormatter.dart';
part 'BoundGrid.dart';
part 'BoundIframe.dart';
part 'BoundImage.dart';
part 'BoundLabel.dart';
part 'BoundList.dart';
part 'BoundRepeater.dart';
part 'BoundSelect.dart';
part 'BoundTextArea.dart';
part 'BoundTextInput.dart';

enum ChangeState
{
	unmodified,
	added,
	deleted,
	modified
}

enum SaveResult
{
	unmodified,
	saved,
	failed,
	notsaved
}
