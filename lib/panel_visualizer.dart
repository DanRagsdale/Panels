import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:panels/panel_data.dart';
import 'package:panels/uw_check_controller.dart';

import 'editor_page.dart';
import 'uw_separator.dart';
import 'uw_check.dart';
import 'uw_text.dart';
import 'user_widget.dart';

/// The widget that displays a NotePanel in its various configurations
/// Also serves as a liason between the individual UserWidgets and the PanelData
class PanelVisualizer extends StatefulWidget {
	final PanelData initialPage;
	final Mode mode;
	
	PanelVisualizer({required this.initialPage, required this.mode});

	@override
	State<StatefulWidget> createState() => PanelVisualizerState();
}

/// Enum that is used for organizing and generating all of the buttons the user
/// may use to add widgets in edit mode
enum WidgetButtons {
	text(icon: Icons.wysiwyg, description: "Text Box", factory: UWTextFactory.new),
	check(icon: Icons.checklist, description: "Check Box", factory: UWCheckFactory.new),
	image(icon: Icons.image_outlined, description: "Image", factory: UWCheckFactory.new), // TODO create factory
	separator(icon: Icons.horizontal_rule, description: "Divider", factory: UWSeparatorFactory.new),

	checkController(icon: Icons.clear_all_outlined, description: "Check Controller", factory: UWCheckControllerFactory.new),
	form(icon: Icons.view_list_outlined, description: "Form", factory: UWTextFactory.new); // TODO create factory

	const WidgetButtons({
		required this.icon,
		required this.description,
		required this.factory,
	});

	final IconData icon;
	final String description;
	final UWFactory Function(GlobalKey) factory;


	IconButton getIconButton(Function(UWFactory) addFunc) {
		return IconButton(
			icon: Icon(icon),
			tooltip: description,
			onPressed: () => addFunc(factory(GlobalKey())),
		);
	}

	PopupMenuItem getMenuItem(Function(UWFactory) addFunc) {
		return PopupMenuItem( 
			value: this.index,
			onTap: () => addFunc(factory(GlobalKey())),
			child: Row(
				children: [
					Icon(icon),
					SizedBox(
						width: 10,
					),
					Text(description)
				],
			),
		);
	}
}

class PanelVisualizerState extends State<PanelVisualizer> {
	late PanelData widgetPage;

	// These functions update the backend AND force the list to update its display 
	void add(UWFactory w) => setState(() => widgetPage.add(w));
	void insert(int index, UWFactory w) => setState(() => widgetPage.insert(index, w));
	void insertAfter(Key k, UWFactory w) => setState(() => widgetPage.insertAfter(k, w));
	void remove(Key k) => setState(() => widgetPage.remove(k));

	/// Sends the message to every single widget factory,
	/// including the one which sends the message
	void broadcastMessage(WidgetMessage message) {
		for (var w in widgetPage.widgetFactories) {
			w.receiveMessage(message);
		}
		setState(() {});
	}
	
	/// Send the message to every widget factory after initial, until
	/// receive message returns false
	void propagateMessage(UWFactory initial, WidgetMessage message) {
		int index = widgetPage.widgetFactories.indexOf(initial);

		if (index != -1) {
			while (++index < widgetPage.length && widgetPage.widgetFactories[index].receiveMessage(message));
			setState(() {});
		}
	}
	
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
			children: widgetPage.buildWidgetList(this, Mode.edit),
		);

		return Column(
			children: [
				Expanded(
					child: moveableList,
				),
				Row(
					mainAxisAlignment: MainAxisAlignment.spaceBetween,
					children: [
						Expanded(
							child: Row(
								mainAxisAlignment: MainAxisAlignment.spaceEvenly,
								children: [
									WidgetButtons.text.getIconButton(add),
									WidgetButtons.check.getIconButton(add),
									WidgetButtons.image.getIconButton(add),
									WidgetButtons.separator.getIconButton(add),
								],
							),
						),
						PopupMenuButton(
							icon: Icon(Icons.more_vert),
							tooltip: "More Widgets",
							offset: Offset(0.0, -120.0),

							itemBuilder: (context) => [
								WidgetButtons.checkController.getMenuItem(add),
								WidgetButtons.form.getMenuItem(add),
							],
							//onSelected: (index) {
							//	add(WidgetButtons.getFactoryByIndex(index));
							//},
						),
					],
				),
			],
		);
	}
	
	@override
	void dispose() {
		super.dispose();
	}
}