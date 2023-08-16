import 'package:flutter/material.dart';
import 'package:panels/panel_controller.dart';
import 'package:panels/panel_page.dart';

import 'main.dart';

enum Mode {view, edit}

class EditorPage extends StatefulWidget {
	final PanelPage initialPage;

	EditorPage({required this.initialPage, Key? key}) : super(key: key);

	@override
	State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
	TextEditingController _titleController = TextEditingController();
	
	int modeIndex = 0;
	Mode mode = Mode.view;

	@override
	Widget build(BuildContext context) {
		_titleController.text = widget.initialPage.title;

		print("Rebuilding page 2");

		return Scaffold(
			appBar: AppBar(
				backgroundColor: COLOR_MENU_BG,
				foregroundColor: COLOR_TEXT,
				title: TextField(
					decoration: null,
					controller: _titleController,
					style: TextStyle(fontWeight: FontWeight.bold),
					onChanged: (value) => widget.initialPage.title = value,
				),
			),
			body: Container(
				color: COLOR_BACKGROUND,
				child: PanelController(initialPage: widget.initialPage, mode: mode),
			),
			bottomNavigationBar: BottomNavigationBar(
				backgroundColor: COLOR_MENU_BG,
				selectedItemColor: COLOR_MENU_HOT,
				unselectedItemColor: COLOR_MENU_COLD,
				currentIndex: modeIndex,
				onTap: (index) {setState(() {
				  modeIndex = index;
					mode = index == 0 ? mode = Mode.view : Mode.edit;
				});},
				items: [
					BottomNavigationBarItem(icon: Icon(Icons.view_column), label: "View Mode"),
					BottomNavigationBarItem(icon: Icon(Icons.edit), label: "Edit Mode"),
				],
			),
		);
	}

	@override
	void dispose() {
		_titleController.dispose();
		super.dispose();
	}
}