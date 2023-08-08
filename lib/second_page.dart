import 'package:flutter/material.dart';
import 'package:panels/user_widget.dart';

import 'main.dart';
import 'uw_separator.dart';
import 'uw_text.dart';
import 'uw_check.dart';

enum Mode {view, edit}

class UWBuilder extends SliverChildDelegate{
	final Mode mode;
	final UWDisplayState widgetController;
	
	UWBuilder(this.mode, this.widgetController);

	@override
	Widget? build(BuildContext context, int index) {
		if (index < widgetController.widgets.length){
			return widgetController.widgets[index].build(context, mode);
		}
		return null;
	}

	@override
	bool shouldRebuild(covariant UWBuilder oldDelegate) {
		//TODO optimize UserWidget shouldRebuild
		return true;
	}
}

class UWDisplay extends StatefulWidget {
	final Mode mode;
	UWDisplay(this.mode);

	@override
	State<StatefulWidget> createState() => UWDisplayState();
}

class UWDisplayState extends State<UWDisplay> {
	List<UserWidget> widgets = [];

	UWDisplayState(){
		widgets.add(UWSeparator(this));
		widgets.add(UWCheck(this));
		widgets.add(UWText(this));
	}

	void add(UserWidget w) {
		setState(() {
			widgets.add(w);
		});
	}
	
	void remove(UserWidget w){
		setState(() {
			widgets.remove(w);
		});
	}

	@override
	Widget build(BuildContext context) {
		UWBuilder testBuilder = UWBuilder(widget.mode, this);

		return ListView.custom(
			padding: const EdgeInsets.all(6),
			childrenDelegate: testBuilder,
		);
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
	Mode mode = Mode.view;

	//UWController widgetController = UWController();

	@override
	Widget build(BuildContext context) {
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
				child: UWDisplay(mode),
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