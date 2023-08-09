import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';

import 'second_page.dart';
import 'uw_separator.dart';
import 'uw_check.dart';
import 'uw_text.dart';

// Class for user editable widgets
// Within flutter, this functions as a widget builder, not a proper flutter widget
abstract class UserWidget {
	final UWControllerState widgetController;
	
	UserWidget(this.widgetController);

	Widget build(BuildContext context, Mode mode);
}

class UWController extends StatefulWidget {
	final Mode mode;
	UWController(this.mode);

	@override
	State<StatefulWidget> createState() => UWControllerState();
}

// Backend for the procedural list of user widgets
class UWControllerState extends State<UWController> {
	List<UserWidget> widgets = [];

	// Test constructor
	UWControllerState(){
		widgets.add(UWSeparator(this));
		widgets.add(UWCheck(this));
		widgets.add(UWText(this));
	}

	void add(UserWidget w) {
		setState(() {
			widgets.add(w);
		});
	}

	// Inserts widget w into the list immediatly after widget i
	void insertAfter(UserWidget i, UserWidget w) {
		int index = widgets.indexOf(i);
		if (index >= 0) {
			setState(() {
				widgets.insert(index + 1, w);
			});
		}
	}
	
	void remove(UserWidget w){
		setState(() {
			widgets.remove(w);
		});
	}

	// Flutter code
	@override
	Widget build(BuildContext context) {
		// View Mode display
		if(widget.mode == Mode.view) {
			return ListView(
				children: widgets.map((e) => e.build(context, widget.mode)).toList(),
			);
		}

		// Edit Mode display
		List<DragAndDropList> _contents = [
			DragAndDropList(
				children: widgets.map((e) => DragAndDropItem(child: e.build(context, widget.mode))).toList(),
			),
		];

		return Column(
			children: [
				Expanded(
					child: DragAndDropLists(
						removeTopPadding: true,
						itemDragOnLongPress: false,
						onItemReorder: (int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
							setState(() {
								var movedItem = widgets.removeAt(oldItemIndex);
								widgets.insert(newItemIndex, movedItem);
							});  
						},
						onListReorder: (int oldListIndex, int newListIndex) {  },
						children: _contents,
					),
				),
				Row(
					mainAxisAlignment: MainAxisAlignment.spaceEvenly,
					children: [
						IconButton(icon: Icon(Icons.wysiwyg), tooltip: "New Text Box", onPressed: () {add(UWText(this));},),
						IconButton(icon: Icon(Icons.checklist), tooltip: "New Check Box", onPressed: () {add(UWCheck(this));},),
						IconButton(icon: Icon(Icons.horizontal_rule), tooltip: "New Divider", onPressed: () {add(UWSeparator(this));},),
					],
				),
			],
		);
	}
}