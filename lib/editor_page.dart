import 'package:flutter/material.dart';
import 'package:panels/panel_visualizer.dart';
import 'package:panels/panel_data.dart';

import 'main.dart';

enum Mode {view, edit}

class EditorPage extends StatefulWidget {
	final PanelData initialPage;

	EditorPage({required this.initialPage, Key? key}) : super(key: key);

	@override
	State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
	TextEditingController _titleController = TextEditingController();
	Mode mode = Mode.view;

	@override
	void initState() {
		super.initState();
		widget.initialPage.readFile().then((value) {
			setState(() {
				_titleController.text = value;
			});
		});
	}

	@override
	Widget build(BuildContext context) {
		_titleController.text = widget.initialPage.title;

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
				child: PanelVisualizer(initialPage: widget.initialPage, mode: mode),
			),
			bottomNavigationBar: BottomNavigationBar(
				backgroundColor: COLOR_MENU_BG,
				selectedItemColor: COLOR_MENU_HOT,
				unselectedItemColor: COLOR_MENU_COLD,
				currentIndex: mode.index,
				onTap: (index) {setState(() {
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
		widget.initialPage.saveFile();
		_titleController.dispose();
		super.dispose();
	}
}