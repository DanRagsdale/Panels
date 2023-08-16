import 'package:flutter/material.dart';
import 'package:panels/panel_controller.dart';
import 'package:panels/user_widget.dart';

import 'editor_page.dart';

abstract class UserWidgetFactory {
	final Key key;
	UserWidgetFactory(this.key);

	UserWidget build(PanelControllerState page, Mode mode);

	String previewString();
}

class PanelPage {
	String title;
	List<UserWidgetFactory> widgetFactories;

	PanelPage(this.title, this.widgetFactories);


	String getPreview() {
		String output = "";
		for (var w in widgetFactories) {
			output += w.previewString() + "\n";
		}

		return output;
	}

	// Widget list methods
	void add(UserWidgetFactory w) => widgetFactories.add(w);
	
	void insert(int index, UserWidgetFactory w) {
		widgetFactories.insert(index, w);
	}

	// Inserts widget w into the list immediatly after widget with key k
	void insertAfter(Key k, UserWidgetFactory w) {
		int index = widgetFactories.indexWhere((e) => e.key == k);
		if (index >= 0) {
			widgetFactories.insert(index + 1, w);
		}
	}

	void remove(Key k){
		widgetFactories.removeWhere((e) => (e.key == k));
	}
	
	UserWidgetFactory removeAt(int index) {
		return widgetFactories.removeAt(index);
	}

	List<UserWidget> buildWidgetList(PanelControllerState controller, Mode mode) {
		List<UserWidget> outputList = [];

		for (var w in widgetFactories) {
			outputList.add(w.build(controller, mode));
		}

		return outputList;
	}
}