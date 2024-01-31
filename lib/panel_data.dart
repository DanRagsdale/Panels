import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:panels/panel_visualizer.dart';
import 'package:panels/user_widget.dart';

import 'main.dart';

class WidgetEntry {
   UWFactory uw;
   bool selected;
   WidgetEntry(this.uw, this.selected);
 }

/// The backend data structure used to represent and manipulate a NotePanel
class PanelData {
	/// The title of this NotePanel, as is dispalyed at the top of the UI
	String title;
	/// The list of user widgets in this NotePanel
	List<WidgetEntry> widgetEntries;
	/// The underlying file which represents this NotePanel
	File file;

	PanelData._(this.title, this.file, List<UWFactory> factories) : this.widgetEntries = factories.map((e) => WidgetEntry(e, false)).toList();

	static Future<PanelData> newWithFile({required File file, List<UWFactory> factories = const [],}) async {
		PanelData pd = PanelData._(DEFAULT_NOTE_TITLE, file, factories);
		pd.saveFile();
		return pd;
	}

	static Future<PanelData> fromFile(File file) async {
		PanelData pd = PanelData._("Unable to read file", file, []);
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
			widgetEntries = [];

			var widgetJson = contents["widgets"];

			for (var w in widgetJson) {
				UWFactory fac = UWFactory.fromJsonMap(w);
				widgetEntries.add(WidgetEntry(fac, false));
			}
		} catch (e) {}
	}
	
	Future<void> saveFile() async {
		try {
			var widgetMaps = [];
			for (var w in widgetEntries) {
				widgetMaps.add(w.uw.toJsonMap());
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
	int get length => widgetEntries.length;

	List<UWFactory> get widgetFactories => widgetEntries.map<UWFactory>((e) => e.uw).toList();

	void add(UWFactory w) => widgetEntries.add(WidgetEntry(w, false));
	void insert(int index, UWFactory w) => widgetEntries.insert(index, WidgetEntry(w, false));

	// Inserts widget w into the list immediatly after widget with key k
	void insertAfter(Key k, UWFactory w) {
		int index = widgetEntries.indexWhere((e) => e.uw.key == k);
		if (index >= 0) {
			widgetEntries.insert(index + 1, WidgetEntry(w, false));
		}
	}

	void remove(Key k){
		widgetEntries.removeWhere((e) => (e.uw.key == k));
	}
	
	UWFactory removeAt(int index) {
		return widgetEntries.removeAt(index).uw;
	}

	void setSelection(int index, bool state) {
		this.widgetEntries[index].selected = state;
	}

	void toggleSelection(int index) {
		var w = this.widgetEntries[index];
		w.selected = !w.selected;
	}

	void clearSelections() {
		for (var w in widgetEntries) {
			w.selected = false;
		}
	}

	void deleteSelected() {
		widgetEntries.removeWhere((e) => e.selected);
	}

	/// Get the string preview of this widget for use in the main menu
	String getPreview() {
		String output = "";
		for (var w in widgetEntries) {
			var preview = w.uw.previewString();
			if (preview.isNotEmpty) {
				output += preview + "\n";
			}
		}

		return output;
	}

	/// The primary build function used to create displayable widgets from the backend data structure.
	/// Return the user widget at the given index for the given mode.
	/// Returns null if the index is out of range
	UserWidget? buildWidget(PanelVisualizerState controller, Mode mode, int index) {
		if (index >= this.length) {
			return null;
		}
		var w = widgetEntries[index];
		return w.uw.build(controller, mode, w.selected);
	}

	/// Generate all widgets and return them as a list	
	List<UserWidget> buildWidgetList(PanelVisualizerState controller, Mode mode) {
		List<UserWidget> outputList = [];

		for (var w in widgetEntries) {
			outputList.add(w.uw.build(controller, mode, w.selected));
		}

		return outputList;
	}
}