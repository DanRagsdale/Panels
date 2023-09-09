import 'dart:async';
import 'dart:convert';
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

	static Future<PanelData> newWithFile({required File file, List<UWFactory> factories = const [],}) async {
		PanelData pd = PanelData._("Untitled Note", factories, file);
		pd.saveFile();
		return pd;
	}

	static Future<PanelData> fromFile(File file) async {
		PanelData pd = PanelData._("Unable to read file", [], file);
		await pd.readFile();

		return pd;
	}
	
	// Serialization methods
	Future<void> readFile() async {
		try {
			// Read the file
			final rawContents = await file.readAsString();
			final contents = jsonDecode(rawContents);
			
			title = contents["title"];
			widgetFactories = [];

			var widgetJson = contents["widgets"];

			for (var w in widgetJson) {
				UWFactory fac = UWFactory.fromJsonMap(w);
				widgetFactories.add(fac);
			}
		} catch (e) {}
	}
	
	Future<void> saveFile() async {
		try {
			var widgetMaps = [];
			for (var w in widgetFactories) {
				widgetMaps.add(w.toJsonMap());
			}
			// Write the file
			var output = jsonEncode({
				"title" : title,
				"widgets" : widgetMaps,
			});

			file.writeAsString(output);
		} catch(e) {}
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

	/// Get the string preview of this widget for use in the main menu
	String getPreview() {
		String output = "";
		for (var w in widgetFactories) {
			var preview = w.previewString();
			if (preview.isNotEmpty) {
				output += preview + "\n";
			}
		}

		return output;
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