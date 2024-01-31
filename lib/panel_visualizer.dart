import 'dart:async';

import 'package:flutter/material.dart';
import 'package:panels/panel_data.dart';
import 'package:panels/uw_check_controller.dart';
import 'package:panels/uw_form.dart';

import 'main.dart';
import 'uw_separator.dart';
import 'uw_check.dart';
import 'uw_text.dart';
import 'user_widget.dart';

enum Mode {view, edit}

/// Enum that is used for organizing and generating all of the buttons the user
/// may use to add widgets in edit mode
enum WidgetButtons {
	text(icon: Icons.wysiwyg, description: "Text Box", factory: UWTextFactory.new),
	check(icon: Icons.checklist, description: "Check Box", factory: UWCheckFactory.new),
	image(icon: Icons.image_outlined, description: "Image", factory: UWCheckFactory.new), // TODO create factory
	separator(icon: Icons.horizontal_rule, description: "Divider", factory: UWSeparatorFactory.new),

	checkController(icon: Icons.clear_all_outlined, description: "Check Controller", factory: UWCheckControllerFactory.new),
	form(icon: Icons.view_list_outlined, description: "Form", factory: UWFormFactory.new); // TODO create factory

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

/// The widget that displays a NotePanel in its various configurations
/// Also serves as a liason between the individual UserWidgets and the PanelData
class PanelVisualizer extends StatefulWidget {
	final PanelData initialPage;
	
	PanelVisualizer({required this.initialPage});

	@override
	State<StatefulWidget> createState() => PanelVisualizerState();
}

class PanelVisualizerState extends State<PanelVisualizer> {
	late PanelData widgetPage;

	late Timer saveTimer;
	Mode mode = Mode.view;
	
	TextEditingController _titleController = TextEditingController();

	// Flutter code
	@override
	void initState() {
		super.initState();

		widgetPage = widget.initialPage;
		
		//TODO prevent wasting time reloading if the page is already cached
		widgetPage.readFile().then((_) {
			setState(() {
				_titleController.text = widget.initialPage.title;
			});
		});

		saveTimer = Timer.periodic(
			const Duration(
				seconds: 5,
			),
			(t) {
				if (saveFlag) {
					widgetPage.saveFile();
					saveFlag = false;
				}
			},
		);
	}

	@override
	Widget build(BuildContext context) {
		_titleController.text = widget.initialPage.title;

		var bottomBar = Row(
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
			);

		var content = mode == Mode.view ?
			// View Mode display
			ListView.builder(
				itemBuilder: (context, index) {
					UserWidget? uw = widgetPage.buildWidget(this, Mode.view, index);
					if (uw == null) {
						return null;
					}
					return InkWell(
						onLongPress: () {
							setState(() {
								mode = Mode.edit;
								widgetPage.setSelection(index, true);
							});
						},
						child: Stack(
							children: [
								uw,
								Positioned(
									right: 40,
									top: 0,
									bottom: 0,
									width: 100.0,
									child: AbsorbPointer(),
								),
							],
						)
					);
				},
			) : 
			// Edit Mode display
			ReorderableListView.builder(
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
				itemBuilder: (context, index) {
					UserWidget uw = widgetPage.buildWidget(this, Mode.edit, index)!;
					return InkWell(
						key: Key(uw.key.toString() + "InkWell"),
						onTap: () {
							setState(() {
								widgetPage.toggleSelection(index);
							});
						},
						child: Stack(
							alignment: Alignment.centerRight,
							children: [
								uw,
								// the Ignore Pointer is offset from the right to allow widgets
								// which have an add widget button to function properly.
								// This is a bad solution.
								// TODO create a more robust solution allowing user to select widgets without interfering with the add widget button
								Positioned(
									right: 50,
									top: 0,
									bottom: 0,
									width: 100.0,
									child: AbsorbPointer(),
								),
								//null,
							],
						)
					);
				},
				itemCount: widgetPage.length,
			);
		var topBar = (mode == Mode.view) ? 
			AppBar(
				backgroundColor: COLOR_MENU_BG,
				foregroundColor: COLOR_TEXT,
				title: TextField(
					decoration: null,
					controller: _titleController,
					style: TextStyle(fontWeight: FontWeight.bold),
					onChanged: (value) => widget.initialPage.title = value,
					onTap: () {
						if (_titleController.text == DEFAULT_NOTE_TITLE) {
							_titleController.text = '';
						}
					},
				),
			) : 
			AppBar(
				backgroundColor: COLOR_MENU_BG,
				foregroundColor: COLOR_TEXT,
				leading: IconButton(
					icon: Icon(Icons.close_outlined),
					onPressed: () {
						setState(() {
							mode = Mode.view;
							widgetPage.clearSelections();
						});
					},
				),
				actions: [
					IconButton(
						icon: Icon(Icons.delete),
						onPressed: () {
							setState(() {
							  widgetPage.deleteSelected();
								mode = Mode.view;
							});
						},
					),
				],	
			);

		return Scaffold(
			appBar: topBar,
			body: content,
			bottomNavigationBar: bottomBar,
		);
	}
	
	@override
	void dispose() {
		widget.initialPage.saveFile();
		_titleController.dispose();
		saveTimer.cancel();

		super.dispose();
	}
	
	// Util functions
	// These functions update the backend AND force the list to update its display 
	void add(UWFactory w) {
		setState(() => widgetPage.add(w));
		requestSave();
	}
	void insert(int index, UWFactory w) {
		setState(() => widgetPage.insert(index, w));
		requestSave();
	}
	void insertAfter(Key k, UWFactory w) {
		setState(() => widgetPage.insertAfter(k, w));
		requestSave();
	}
	void remove(Key k) {
		setState(() => widgetPage.remove(k));
		requestSave();
	}

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

	/// Request to save the active NotePanel
	/// By default, the file will be saved at the next periodic save interval
	/// If the immediate flag is set, the file will be saved without waiting 
	bool saveFlag = false;
	void requestSave({bool immediate = false}) {
		if (immediate) {
			saveFlag = false;
			widgetPage.saveFile();
		} else {
			saveFlag = true;
		}
	}

}