import 'package:flutter/material.dart';

import 'main.dart';

class SecondPage extends StatefulWidget {
	final String title;

	SecondPage(this.title, {Key? key}) : super(key: key);

	@override
	State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
	bool isClicked = false;
	int modeIndex = 0;
	TextEditingController _controller = TextEditingController();
	
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
			body: GestureDetector(
				onTap: () {
					setState(() {
						isClicked = !isClicked;
					});
				},
				child: Column(
					children: [
						isClicked ? 
							Image.asset("images/aurora.jpg") :
							Image.network("https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/NGC_4414_%28NASA-med%29.jpg/726px-NGC_4414_%28NASA-med%29.jpg"),
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