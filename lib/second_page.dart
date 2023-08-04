import 'package:flutter/material.dart';
import 'package:panels/uw_text.dart';

import 'main.dart';
import 'uw_separator.dart';

enum Mode {view, edit}

class SecondPage extends StatefulWidget {
	final String title;

	SecondPage(this.title, {Key? key}) : super(key: key);

	@override
	State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
	TextEditingController _controller = TextEditingController();
	
	int modeIndex = 0;
	String imageSrc = "images/aurora.jpg";
	Mode mode = Mode.view;
	
	@override
	Widget build(BuildContext context) {
		_controller.text = widget.title;

		return Scaffold(
			appBar: AppBar(
				backgroundColor: COLOR_MENU_BG,
				foregroundColor: COLOR_TEXT,
				title: TextField(
					decoration: null,
					controller: _controller,
					style: TextStyle(fontWeight: FontWeight.bold),
				),
			),
			body: Container(
				color: COLOR_BACKGROUND,
				child: ListView(
					padding: const EdgeInsets.all(6),
					children: [
						Column(
							children: [
									Image.asset(imageSrc),
							],
						),
						UWSeparator(mode: mode),
						UWText(mode),
					],
				),
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
				]),
		);
	}

	@override
	void dispose() {
		_controller.dispose();
		super.dispose();
	}
}