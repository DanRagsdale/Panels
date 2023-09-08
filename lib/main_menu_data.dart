import 'dart:io';

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

enum EntryType {
	panel,
	directory,
}

/// Backend data structure that is used to create a PanelIcon in the menu
abstract class MenuEntry {
	EntryType get type;	

	LocalSelectionMode? get mode;
	void set mode(LocalSelectionMode? m);

	Future<FileSystemEntity> deleteFile();
}

class EntryPanel extends MenuEntry {
	LocalSelectionMode? _mode;

	PanelData panel;
	EntryPanel(this.panel, this._mode);
	
	@override
	EntryType get type => EntryType.panel;

	@override	
	LocalSelectionMode? get mode => _mode;
	@override
	void set mode(LocalSelectionMode? m) => _mode = m;
	
	@override
	Future<FileSystemEntity> deleteFile() async {
 		return panel.file.delete();
	}
}

class EntryDirectory extends MenuEntry {
	Directory dir;
	LocalSelectionMode? _mode;

	EntryDirectory(this.dir, this._mode);

	@override
	EntryType get type => EntryType.directory;
	
	@override	
	LocalSelectionMode? get mode => _mode;
	@override
	void set mode(LocalSelectionMode? m) => _mode = m;
	
	@override
	Future<FileSystemEntity> deleteFile() async {
		return dir.delete(recursive: true);
	}
}

/// Data structure representing a menu page in the main menu
class SelectionMenuData {
	List<MenuEntry> menuItems = [];
	GlobalSelectionMode mode = GlobalSelectionMode.view;
	Set<int> selections = {};

	int get length => menuItems.length;
	operator [](int i) => menuItems[i]; // get

	void add(PanelData pd) {
		menuItems.add(EntryPanel(pd, null));
	}

	void addDir(Directory d) {
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

	MenuEntry getMenuContainer(int index) {
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
