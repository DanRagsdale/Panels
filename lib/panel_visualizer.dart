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
		
		// TODO prevent wasting time reloading if the page is already cached.
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

		var topBar = buildTopBar();
		var body = buildBody();
		var bottomBar = buildBottomBar();


		return Scaffold(
			appBar: topBar,
			body: body,
			bottomNavigationBar: bottomBar,
		);
	}

	AppBar buildTopBar() {
		// View Mode
		if (mode == Mode.view) { 
			return AppBar(
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
			);
		}
		// Edit Mode
		int selectionCount = widgetPage.countSelected();
		return AppBar(
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
			title: Text("$selectionCount selected"),
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
	}

	Widget buildBody() {
		// View Mode display
		if (mode == Mode.view) {
			return ListView.builder(
				itemBuilder: (context, index) {
					UserWidget? uw = widgetPage.buildWidget(this, Mode.view, index);
					if (uw == null) {
						return null;
					}
					// TODO figure out a more performant solution
					return IntrinsicHeight(
						child: Stack(
							children: [
								uw,
								GestureDetector(
									behavior: HitTestBehavior.translucent,
									onLongPress: () {
										setState(() {
											mode = Mode.edit;
											widgetPage.setSelection(index, true);
										});
									},
								),
							],
						),
					);
				},
			);
		}
		// Edit Mode display
		return ReorderableListView.builder(
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
				return IntrinsicHeight(
					key: Key(uw.key.toString() + "Clicker"),
					child: Stack(
						children: [
							uw,
							Positioned(
								right: 50,
								top: 0,
								bottom: 0,
								width: 100.0,
								child: GestureDetector(
									behavior: HitTestBehavior.opaque,
									onTap: () {
										setState(() {
											widgetPage.toggleSelection(index);
										});
									},
								),
							),
							GestureDetector(
								behavior: HitTestBehavior.translucent,
								onLongPress: () {
									setState(() {
										widgetPage.toggleSelection(index);
									});
								},
							),
						],
					),
				);
			},
			itemCount: widgetPage.length,
		);
	}

	Widget buildBottomBar() {
		return Row(
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