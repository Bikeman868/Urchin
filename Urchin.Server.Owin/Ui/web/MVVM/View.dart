part of mvvm;

class View extends HtmlBuilder
{
	void hideElement(Element element)
	{
		element.style.display = 'none';
	}

	void showElement(Element element)
	{
		element.style.display = '';
	}

	void reload() { }
}