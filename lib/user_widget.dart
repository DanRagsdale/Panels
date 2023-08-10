import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:panels/user_widget_page.dart';

import 'editor_page.dart';
import 'uw_separator.dart';
import 'uw_check.dart';
import 'uw_text.dart';

// Class for user editable widgets
// Within flutter, this functions as a widget builder, not a proper flutter widget
abstract class UserWidget {
	final PanelControllerState widgetController;
	final Key? key;

	// May remove the requirement for keys.
	// Keys are needed for ReorderableListView but not for DragAndDropLists	
	UserWidget(this.widgetController, {Key? this.key});

	Widget build(BuildContext context, Mode mode);
}

abstract class UserWidgetFactory {
	UserWidget build(PanelControllerState widgetController, {Key? key});
}



class PanelController extends StatefulWidget {
	final PanelPage initialPage;
	final Mode mode;
	
	PanelController({required this.initialPage, required this.mode});

	@override
	State<StatefulWidget> createState() => PanelControllerState();
}

// Backend for the procedural list of user widgets
class PanelControllerState extends State<PanelController> {
	List<UserWidget> widgets = [];

	// Test constructor
	
	@override
	void initState() {
		super.initState();

		widgets = widget.initialPage.BuildWidgetList(this);
	}

	int key_counter = 0;
	Key getKey() {
		key_counter++;
		return Key("UW-" + key_counter.toString());
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
		// Not yet sure which implementation of a reorderable list works better
		// The DragAndDropLists seem more stable, but have some weird behavior

		List<DragAndDropList> _contents = [
			DragAndDropList(
				children: widgets.map((e) => DragAndDropItem(child: e.build(context, widget.mode))).toList(),
			),
		];

		var moveableList = DragAndDropLists(
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
		);
		
		//var moveableList = ReorderableListView(
		//		onReorder: (int oldIndex, int newIndex) {
		//			setState(() { 
		//				if (oldIndex < newIndex) {
		//					// removing the item at oldIndex will shorten the list by 1.
		//					newIndex -= 1;
		//				}
		//				var movedItem = widgets.removeAt(oldIndex);
		//				widgets.insert(newIndex, movedItem);
		//			});  
		//		},
		//		children: widgets.map((e) => e.build(context, widget.mode)).toList(),
		//);
	
		return Column(
			children: [
				Expanded(
					child: moveableList,
				),
				Row(
					mainAxisAlignment: MainAxisAlignment.spaceEvenly,
					children: [
						IconButton(icon: Icon(Icons.wysiwyg), tooltip: "New Text Box", onPressed: () {add(UWText(this, key: getKey()));},),
						IconButton(icon: Icon(Icons.checklist), tooltip: "New Check Box", onPressed: () {add(UWCheck(this, key: getKey()));},),
						IconButton(icon: Icon(Icons.horizontal_rule), tooltip: "New Divider", onPressed: () {add(UWSeparator(this, key: getKey()));},),
					],
				),
			],
		);
	}
}