import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:panels/panel_visualizer.dart';
import 'package:panels/user_widget.dart';

import 'editor_page.dart';

/// The backend data structure used to represent and manipulate a NotePanel
class PanelData {
	String title;
	List<UWFactory> widgetFactories;
	File file;

	PanelData._(this.title, this.widgetFactories, this.file);

	static Future<PanelData> fromFile(File file) async {
		try {
			final title = await file.readAsString();
			return PanelData._(title, [], file);
		} catch (e) {
			return PanelData._("Error!", [], file);
		}
	}

	String getPreview() {
		String output = "";
		for (var w in widgetFactories) {
			output += w.previewString() + "\n";
		}

		return output;
	}

	// Widget list methods
	int get length => widgetFactories.length;

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

	// Serialization methods
	Future<String> readFile() async {
		try {
			// Read the file
			final contents = await file.readAsString();
			title = contents;

			return contents;
		} catch (e) {
			// If encountering an error, return 0
			return "New file";
		}
	}
	
	Future<File> saveFile() async {
		// Write the file
		return file.writeAsString(title);
	}

	/// The primary build function used to convert the data structure into
	/// a list of displable widgets
	List<UserWidget> buildWidgetList(PanelVisualizerState controller, Mode mode) {
		List<UserWidget> outputList = [];

		for (var w in widgetFactories) {
			outputList.add(w.build(controller, mode));
		}

		return outputList;
	}
}