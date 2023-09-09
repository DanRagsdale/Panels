import 'dart:io';

import 'package:flutter/material.dart';
import 'package:panels/main.dart';
import 'package:panels/panel_data.dart';

import 'main_menu_data.dart';

/// Backend data structure representing a NotePanel icon in the menu
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

/// The widget that represents a specifc NotePanel on the main page
class MenuIconPanel extends StatelessWidget {
	final EntryPanel panelMenu;
	
	MenuIconPanel({required this.panelMenu});

	@override
	Widget build(BuildContext context) {
		var note_icon = Container(
			margin: const EdgeInsets.all(4),
			padding: const EdgeInsets.all(8),
			decoration: BoxDecoration(
				color: COLOR_BACKGROUND_HEAVY,
				border: Border.all(
					width: 4,
				),
				borderRadius: BorderRadius.circular(12),
			),
			child: Column(
				children: [
					Text(
						panelMenu.panel.title,
						style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
					Expanded(
						child: Text(panelMenu.panel.getPreview(),
						),
					),
				],
			),
		);

		if (panelMenu.mode == LocalSelectionMode.unselected) {
			return note_icon;
		}

		return Stack(
			children: [
				Positioned.fill(child: note_icon,),
				Checkbox(
					shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
					fillColor: MaterialStateColor.resolveWith((states) => COLOR_MENU_COLD),

					value: panelMenu.mode == LocalSelectionMode.selected,
					onChanged: null,
				),
			],
		);
	}
}