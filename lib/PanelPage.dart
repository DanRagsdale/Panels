import 'package:flutter/material.dart';
import 'package:panels/user_widget.dart';

import 'editor_page.dart';

abstract class UserWidgetFactory {
	final Key key;
	UserWidgetFactory(this.key);

	UserWidget build(PanelControllerState widgetController, Mode mode);
}

class PanelPage {
	List<UserWidgetFactory> widgetFactories;

	PanelPage(this.widgetFactories);

	void add(UserWidgetFactory w) => widgetFactories.add(w);
	
	void insertAfter(Key k, UserWidgetFactory w) {
		int index = widgetFactories.indexWhere((e) => e.key == k);
		if (index >= 0) {
			widgetFactories.insert(index + 1, w);
		}
	}
	
	void remove(Key k){
		widgetFactories.removeWhere((e) => (e.key == k));
	}

	List<UserWidget> buildWidgetList(PanelControllerState widgetController, Mode mode) {
		List<UserWidget> outputList = [];

		for (var w in widgetFactories) {
			outputList.add(w.build(widgetController, mode));
		}

		return outputList;
	}

	String getPreview() {
		return "Preview!";
	}

	String getTitle() {
		return "Title!";
	}
}