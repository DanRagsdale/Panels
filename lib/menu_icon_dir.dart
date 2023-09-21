import 'dart:io';

import 'package:flutter/material.dart';
import 'package:panels/main.dart';

import 'io_tools.dart';
import 'main_menu_data.dart';

/// Backend data structure representing a directory icon in the menu
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

	@override	
	Future<FileSystemEntity> moveTo(String destDirpath) async {
		var newPath = destDirpath + '/' + dir.fileName;
		return dir.dir.rename(newPath);
	}
}

/// The widget that represents a specifc directory on the main page
class MenuIconDir extends StatelessWidget {
	final EntryDirectory entry;
	
	MenuIconDir({required this.entry});

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
						entry.dir.displayName,
						style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
					),
					Icon(Icons.folder),
				],
			),
		);

		if (entry.mode == LocalSelectionMode.unselected) {
			return note_icon;
		}

		return Stack(
			children: [
				Positioned.fill(child: note_icon,),
				Checkbox(
					shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
					fillColor: MaterialStateColor.resolveWith((states) => COLOR_MENU_COLD),

					value: entry.mode == LocalSelectionMode.selected,
					onChanged: null,
				),
			],
		);
	}
}