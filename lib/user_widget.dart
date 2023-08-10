import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:panels/PanelPage.dart';

import 'editor_page.dart';
import 'uw_separator.dart';
import 'uw_check.dart';
import 'uw_text.dart';

// Class for user editable widgets
// Within flutter, this functions as a widget builder, not a proper flutter widget
abstract class UserWidget extends StatefulWidget {
	final PanelControllerState controller;
	final Mode mode;

	UserWidget(this.controller, this.mode, {required Key key}) : super(key: key);
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
	late PanelPage widgetPage;

	// Test constructor
	
	@override
	void initState() {
		super.initState();

		widgetPage = widget.initialPage;
	}

	// Needed to switch to using GlobalKeys in order to preserve state across mode switches
	//int key_counter = 0;
	//Key getKey() {
	//	key_counter++;
	//	return Key("Proc-" + key_counter.toString());
	//}

	void add(UserWidgetFactory w) {
		setState(() {
			widgetPage.add(w);
		});
	}

	// Inserts widget w into the list immediatly after widget i
	void insertAfter(Key k, UserWidgetFactory w) {
		setState(() {
			widgetPage.insertAfter(k, w);
		});
	}
	
	void remove(Key k){
		setState(() {
			widgetPage.remove(k);
		});
	}

	// Flutter code
	@override
	Widget build(BuildContext context) {
		// View Mode display
		if(widget.mode == Mode.view) {
			return ListView(
				children: widgetPage.buildWidgetList(this, Mode.view),
			);
		}

		// Edit Mode display
		// Not yet sure which implementation of a reorderable list works better
		// The DragAndDropLists seem more stable, but have some weird behavior

		List<DragAndDropList> _contents = [
			DragAndDropList(
				children: widgetPage.buildWidgetList(this, Mode.edit).map((e) => DragAndDropItem(child: e)).toList(),
			),
		];

		var moveableList = DragAndDropLists(
				removeTopPadding: true,
				itemDragOnLongPress: false,
				onItemReorder: (int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
					//setState(() {
					//	var movedItem = widgetPage.removeAt(oldItemIndex);
					//	widgetPage.insert(newItemIndex, movedItem);
					//});  
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
						IconButton(icon: Icon(Icons.wysiwyg), tooltip: "New Text Box", onPressed: () {add(UWTextFactory(GlobalKey()));},),
						IconButton(icon: Icon(Icons.checklist), tooltip: "New Check Box", onPressed: () {add(UWCheckFactory(GlobalKey()));},),
						IconButton(icon: Icon(Icons.horizontal_rule), tooltip: "New Divider", onPressed: () {add(UWSeparatorFactory(GlobalKey()));},),
					],
				),
			],
		);
	}
}