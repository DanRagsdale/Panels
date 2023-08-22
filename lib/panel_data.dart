import 'package:flutter/material.dart';
import 'package:panels/panel_visualizer.dart';
import 'package:panels/user_widget.dart';

import 'editor_page.dart';

/// The backend data structure used to represent a single UserWidget within a NotePanel
/// Stores all persistent information associated with a UserWidget,
/// and can generate the corresponding flutter widget when needed
/// Will be subclassed by each specific UserWidget
abstract class UWFactory<T extends UserWidget> {
	final Key key;
	UWFactory(this.key);

	T build(PanelVisualizerState page, Mode mode);

	/// Receive a WidgetMessage
	/// Return true if the message should continue propagating
	bool receiveMessage(WidgetMessage message) => false;

	String previewString();
}

/// The backend data structure used to represent and manipulate a NotePanel
class PanelData {
	String title;
	List<UWFactory> widgetFactories;

	PanelData(this.title, this.widgetFactories);

	String getPreview() {
		String output = "";
		for (var w in widgetFactories) {
			output += w.previewString() + "\n";
		}

		return output;
	}

	// Widget list methods
	void add(UWFactory w) => widgetFactories.add(w);
	void insert(int index, UWFactory w) => widgetFactories.insert(index, w);

	// Inserts widget w into the list immediatly after widget with key k
	void insertAfter(Key k, UWFactory w) {
		int index = widgetFactories.indexWhere((e) => e.key == k);
		if (index >= 0) {
			widgetFactories.insert(index + 1, w);
		}
	}

	void remove(Key k){
		widgetFactories.removeWhere((e) => (e.key == k));
	}
	
	UWFactory removeAt(int index) {
		return widgetFactories.removeAt(index);
	}

	List<UserWidget> buildWidgetList(PanelVisualizerState controller, Mode mode) {
		List<UserWidget> outputList = [];

		for (var w in widgetFactories) {
			outputList.add(w.build(controller, mode));
		}

		return outputList;
	}
}