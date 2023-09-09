import 'dart:io';

import 'package:panels/main.dart';

import 'panel_data.dart';

/// Enum representing the global section mode of the main menu.
/// Determines which toolbars should be shown
enum GlobalSelectionMode {
	view(defaultLocalMode: LocalSelectionMode.unselected),
	selection(defaultLocalMode: LocalSelectionMode.ready);

	const GlobalSelectionMode({
		required this.defaultLocalMode,
	});

	final LocalSelectionMode defaultLocalMode;
}

// Enum representing different selection states of a PanelIcon
enum LocalSelectionMode {
	unselected,
	ready,
	selected,
}

/// Backend data structure that is used to create an entry in the menu
abstract class MenuEntry {
	LocalSelectionMode? get mode;
	void set mode(LocalSelectionMode? m);

	Future<FileSystemEntity> deleteFile();
}

/// Backend data structure representing a NotePanel in the menu
class EntryPanel extends MenuEntry {
	LocalSelectionMode? _mode;

	PanelData panel;
	EntryPanel(this.panel, this._mode);
	
	@override	
	LocalSelectionMode? get mode => _mode;
	@override
	void set mode(LocalSelectionMode? m) => _mode = m;
	
	@override
	Future<FileSystemEntity> deleteFile() async {
 		return panel.file.delete();
	}
}

/// Backend data structure representing a directory in the menu
class EntryDirectory extends MenuEntry {
	DirContainer dir;
	LocalSelectionMode? _mode;

	EntryDirectory(this.dir, this._mode);

	@override	
	LocalSelectionMode? get mode => _mode;
	@override
	void set mode(LocalSelectionMode? m) => _mode = m;
	
	@override
	Future<FileSystemEntity> deleteFile() async {
		return dir.dir.delete(recursive: true);
	}

	String get fileName {
		return dir.path.split('/').last;
	}

	String get displayName {
		return fileName.split('-*-').last;
	}
}

/// Data structure representing a menu page in the main menu
class SelectionMenuData {
	List<MenuEntry> menuItems = [];
	GlobalSelectionMode mode = GlobalSelectionMode.view;
	Set<int> selections = {};

	int get length => menuItems.length;
	operator [](int i) => menuItems[i]; // get

	void addPanel(PanelData pd) {
		menuItems.add(EntryPanel(pd, null));
	}

	void addDir(DirContainer d) {
		menuItems.add(EntryDirectory(d, null));
	}

	/// Remove every selected PanelData
	/// DOES NOT delete the underlying files. This must be handled separately
	List<MenuEntry> removeSelected() {
		List<MenuEntry> removals = [];
		for (var i in selections) {
			removals.add(menuItems[i]);
		}
		for (var pd in removals) {
			menuItems.remove(pd);
		}
		deselectAll();
		return removals;
	}

	MenuEntry getMenuEntry(int index) {
		if (selections.contains(index)) {
			MenuEntry item = menuItems[index];
			item.mode = LocalSelectionMode.selected;
			return item;
		}
		MenuEntry item = menuItems[index];
		item.mode = mode.defaultLocalMode;
		return item;
	}

	void select(int index) {
		mode = GlobalSelectionMode.selection;
		selections.add(index);
		//panels[index].mode = LocalSelectionMode.ready;
	}
	
	void toggleSelection(int index) {
		mode = GlobalSelectionMode.selection;
		bool flag = selections.add(index);
		if (!flag) {
			selections.remove(index);
		}
	}

	void selectAll() {
		mode = GlobalSelectionMode.selection;
		selections.addAll(Iterable<int>.generate(length));
	}

	void deselectAll() {
		mode = GlobalSelectionMode.view;
		selections = {};
	}
}
