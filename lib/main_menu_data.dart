import 'dart:io';

import 'io_tools.dart';
import 'menu_icon_dir.dart';
import 'menu_icon_panel.dart';
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

enum SortMode {
	alphabetical(_alphaSort);

	const SortMode(this.compFunction);

	final int Function(MenuEntry a, MenuEntry b) compFunction;

	static int _alphaSort(MenuEntry a, MenuEntry b) {
		if (a is EntryDirectory && b is EntryPanel) {
			return -1;
		} else if (a is EntryPanel && b is EntryDirectory) {
			return 1;
		}
		
		return a.displayName.compareTo(b.displayName);
	}
}

/// Backend data structure that is used to represent an entry in the menu
abstract class MenuEntry {
	LocalSelectionMode? get mode;
	void set mode(LocalSelectionMode? m);

	String get displayName;

	Future<FileSystemEntity> deleteFile();
	Future<FileSystemEntity> moveTo(String destDirPath);
}

/// Data structure representing the files and folders in the main menu
class SelectionMenuData {
	List<MenuEntry> menuItems = [];
	GlobalSelectionMode mode = GlobalSelectionMode.view;
	Set<int> selections = {};

	int get length => menuItems.length;
	operator [](int i) => menuItems[i];

	void addPanel(PanelData pd) {
		menuItems.add(EntryPanel(pd, null));
	}

	void addDir(DirContainer d) {
		menuItems.add(EntryDirectory(d, null));
	}

	void sort(SortMode sortMode, {bool reversed = false}) {
		deselectAll();
		
		int multiplier = reversed ? -1 : 1;
		
		menuItems.sort((a,b) {
			return sortMode.compFunction(a, b) * multiplier;
		});
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

	bool isSelectedDir(Directory dir){
		for (var i in selections) {
			MenuEntry entry = menuItems[i];
			if (entry is EntryDirectory) {
				if (entry.dir.path == dir.path) {
					return true;
				}
			}
		}
		return false;
	}

	int get selectedCount => selections.length;

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
