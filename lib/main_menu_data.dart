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

/// Backend data structure that is used to create a PanelIcon in the menu
class PanelIconData {
	PanelData panel;
	LocalSelectionMode mode;

	PanelIconData(this.panel, this.mode);
}

/// Data structure representing a menu page in the main menu
class SelectionMenuData {
	List<PanelData> panels = [];
	GlobalSelectionMode mode = GlobalSelectionMode.view;
	Set<int> selections = {};

	int get length => panels.length;
	operator [](int i) => panels[i]; // get

	void add(PanelData pd) {
		panels.add(pd);
	}

	/// Remove every selected PanelData
	/// DOES NOT delete the underlying files. This must be handled separately
	List<PanelData> removeSelected() {
		List<PanelData> removals = [];
		for (var i in selections) {
			removals.add(panels[i]);
		}
		for (var pd in removals) {
			panels.remove(pd);
		}
		deselectAll();
		return removals;
	}

	PanelIconData getMenuContainer(int index) {
		if (selections.contains(index)) {
			return PanelIconData(panels[index], LocalSelectionMode.selected);
		}
		return PanelIconData(panels[index], mode.defaultLocalMode);
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
