import 'package:flutter/material.dart';
import 'package:panels/panel_page.dart';

import 'editor_page.dart';
import 'uw_separator.dart';
import 'uw_check.dart';
import 'uw_text.dart';

class PanelController extends StatefulWidget {
	final PanelPage initialPage;
	final Mode mode;
	
	PanelController({required this.initialPage, required this.mode});

	@override
	State<StatefulWidget> createState() => PanelControllerState();
}

// Controller for the procedural list of user widgets
class PanelControllerState extends State<PanelController> {
	late PanelPage widgetPage;

	// These functions update the backend AND force the list to update its display 
	void add(UWFactory w) => setState(() => widgetPage.add(w));
	void insert(int index, UWFactory w) => setState(() => widgetPage.insert(index, w));
	void insertAfter(Key k, UWFactory w) => setState(() => widgetPage.insertAfter(k, w));
	void remove(Key k) => setState(() => widgetPage.remove(k));

	
	
	// Flutter code
	@override
	void initState() {
		super.initState();

		widgetPage = widget.initialPage;
	}

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
		// DragAndDropLists throw GlobalKeyExceptions, which is annoying
		// ReorderableList occasionally freezes, seemingly at random

		//List<DragAndDropList> _contents = [
		//	DragAndDropList(
		//		children: widgetPage.buildWidgetList(this, Mode.edit).map((e) => DragAndDropItem(child: e)).toList(),
		//	),
		//];

		//var moveableList = DragAndDropLists(
		//		removeTopPadding: true,
		//		itemDragOnLongPress: false,
		//		onItemReorder: (int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
		//			setState(() {
		//				var movedItem = widgetPage.removeAt(oldItemIndex);
		//				insert(newItemIndex, movedItem);
		//			});
		//		},
		//		onListReorder: (int oldListIndex, int newListIndex) {  },
		//		children: _contents,
		//);

		var reorderableChildren = widgetPage.buildWidgetList(this, Mode.edit);
		//List<Widget> reorderableChildren = [];
		//var widgetList = widgetPage.buildWidgetList(this, Mode.edit);
		//for (int i = 0; i < widgetList.length; i++) {
		//	reorderableChildren.add(
		//		ReorderableDragStartListener(
		//			key: Key("List-" + i.toString()),
		//			index: i,
		//			child: InkWell(
		//				child: widgetList[i]
		//			),
		//		),
		//	);
		//}

		var moveableList = ReorderableListView(
				//buildDefaultDragHandles: false,
				onReorderStart: (index) {
					// Needed to prevent freezing when the items are moved
					FocusManager.instance.primaryFocus?.unfocus();
				},
				onReorder: (int oldIndex, int newIndex) {
					setState(() { 
						if (oldIndex < newIndex) {
							// removing the item at oldIndex will shorten the list by 1.
							newIndex -= 1;
						}
						var movedItem = widgetPage.removeAt(oldIndex);
						widgetPage.insert(newIndex, movedItem);
					});  
				},
				children: reorderableChildren,
		);
	
		return Column(
			children: [
				Expanded(
					child: moveableList,
				),
				Row(
					mainAxisAlignment: MainAxisAlignment.spaceEvenly,
					children: [
						IconButton(
							icon: Icon(Icons.wysiwyg),
							tooltip: "New Text Box",
							onPressed: () => add(UWTextFactory(GlobalKey())),
						),
						IconButton(
							icon: Icon(Icons.checklist),
							tooltip: "New Check Box",
							onPressed: () => add(UWCheckFactory(GlobalKey())),
						),
						IconButton(
							icon: Icon(Icons.horizontal_rule),
							tooltip: "New Divider",
							onPressed: () => add(UWSeparatorFactory(GlobalKey())),
						),
						IconButton(
							icon: Icon(Icons.more_vert),
							tooltip: "More Widgets",
							onPressed: () {},
						),
					],
				),
			],
		);
	}
	
	@override
	void dispose() {
		//for (int i = 0; i < widgetPage.widgetFactories.length; i++) {
		//	widgetPage.widgetFactories[i] = widgetPage.widgetFactories[i].save();
		//}
		super.dispose();
	}
}