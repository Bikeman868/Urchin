import 'dart:html';

abstract class View
{
  void addTo(Element container);
  void displayIn(Element container);
}