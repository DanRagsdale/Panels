import 'package:flutter/material.dart';
import 'package:panels/user_widget.dart';

import 'main.dart';
import 'uw_separator.dart';
import 'uw_text.dart';
import 'uw_check.dart';

enum Mode {view, edit}

enum UserWidgets {separator, text, check}

class UWController{
	List<UserWidget> widgets = [];

	void add(UserWidget w) {
		widgets.add(w);
	}
	
	//void remove()
}

class UWBuilder extends SliverChildDelegate{
	final Mode mode;
	final UWController _controller;
	
	UWBuilder(this.mode, this._controller);

	@override
	Widget? build(BuildContext context, int index) {
		if (index < _controller.widgets.length){
			return _controller.widgets[index].build(context, mode);
		}
		return null;
	}

	@override
	bool shouldRebuild(covariant UWBuilder oldDelegate) {
		return oldDelegate.mode != mode;
	}
}

class SecondPage extends StatefulWidget {
	final String title;

	SecondPage(this.title, {Key? key}) : super(key: key);

	@override
	State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
	TextEditingController titleController = TextEditingController();
	
	int modeIndex = 0;
	String imageSrc = "images/aurora.jpg";
	Mode mode = Mode.view;

	UWController widgetController = UWController();

	_SecondPageState(){
		widgetController.add(UWSeparator());
		widgetController.add(UWText());
		widgetController.add(UWCheck());
	}

	@override
	Widget build(BuildContext context) {
		UWBuilder testBuilder = UWBuilder(mode, widgetController);
		
		titleController.text = widget.title;

		return Scaffold(
			appBar: AppBar(
				backgroundColor: COLOR_MENU_BG,
				foregroundColor: COLOR_TEXT,
				title: TextField(
					decoration: null,
					controller: titleController,
					style: TextStyle(fontWeight: FontWeight.bold),
				),
			),
			body: Container(
				color: COLOR_BACKGROUND,
				child: ListView.custom(
					padding: const EdgeInsets.all(6),
					childrenDelegate: testBuilder,
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
		titleController.dispose();
		super.dispose();
	}
}