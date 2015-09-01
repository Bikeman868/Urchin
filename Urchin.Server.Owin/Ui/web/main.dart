import 'dart:html';
import 'dart:convert';

void main() {
  var menu = querySelector('#menuDiv');

  var button = new ButtonElement();
  button.text = "Get Rules";
  button.onClick.listen(fetchRules);
  menu.children.add(button);
}

void fetchRules(MouseEvent e){
  var data = new Data();
  var div = querySelector('#centreDiv');
  data.getRules()
	..then((r) => displayRules(div, r))
	..catchError((e) => div.text = e.toString());	
}

void displayRules(div, rules){
  var list = new UListElement();
  for (var rule in rules){
    var element = new LIElement();
	element.text = rule['name'];
	list.children.add(element);
  }
  div.children.clear();
  div.children.add(list);
}

class Data{
	getRules() async {
		String content = await HttpRequest.getString('/rules');
		return JSON.decode(content);
	}
}
