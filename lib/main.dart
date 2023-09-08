import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:panels/dir_icon.dart';
import 'package:path_provider/path_provider.dart';

import 'package:panels/panel_data.dart';

import 'panel_icon.dart';
import 'editor_page.dart';
import 'main_menu_data.dart';

const Color COLOR_TEXT = Color(0xff000000);
//const Color COLOR_MENU_TEXT = Color(0xff2E272D);
const Color COLOR_BACKGROUND = Color(0xffEDF6F9);
const Color COLOR_BACKGROUND_MID = Color.fromARGB(255, 220, 227, 230);
const Color COLOR_BACKGROUND_HEAVY = Color.fromARGB(255, 157, 164, 197);

const Color COLOR_MENU_BG = Color(0xffFFDDD2);
const Color COLOR_MENU_HOT = Color(0xff4FC5B9);
const Color COLOR_MENU_COLD = Color.fromARGB(255, 2, 81, 88);

void main() {
	runApp(MyApp());
}

class MyApp extends StatefulWidget {
	MyApp({Key? key}) : super(key: key);

	@override
	State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			//debugShowCheckedModeBanner: false,
			home: MainPage(),
		);
	}
}

class MainPage extends StatefulWidget {
	@override
	State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
	SelectionMenuData menuData = SelectionMenuData();

	@override
	void initState() {
		super.initState();
		readFiles();
	}

	@override
	Widget build(BuildContext context) {
		// TODO add trash can and undo functions when deleting
	
		//var snackBar = SnackBar(
		//	padding: EdgeInsets.only(left: 8.0, right: 8.0),
		//	content: Row(
		//		children: [
		//			Text("Items moved to trash"),
		//			Spacer(),
		//			TextButton(
		//				child: Text("Undo"),
		//				onPressed: () {
		//				},
		//			),
		//		],
		//	),
		//);

		// Top toolbar widget
		late Widget topBar;
		if (menuData.mode == GlobalSelectionMode.view) {
			topBar = const Text("Panels");
		} else {
			topBar = Row(
				children: [
					IconButton(
						icon: Icon(Icons.close_outlined),
						onPressed: () {
							setState(() {
								menuData.deselectAll();
							});
						},
					),
					Spacer(),
					IconButton(
						icon: Icon(Icons.delete),
						onPressed: () {
							deleteSelected().then((value) {
								//ScaffoldMessenger.of(context).showSnackBar(snackBar).closed.then(
								//	(value) {}
								//);
								setState(() {});
							});
						})
				],
			);
		}

		return Scaffold(
			appBar: AppBar(
				title: topBar,
				foregroundColor: COLOR_TEXT,
				backgroundColor: COLOR_MENU_BG,
			),

			drawer: menuData.mode != GlobalSelectionMode.view ? null : Drawer(
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					
					children: [
						Container(
							width: double.infinity,
							child: const DrawerHeader(
								decoration: BoxDecoration(
									color: COLOR_MENU_BG,
								),
								child: const Text('Panels'),
							),
						),
						ListTile(
							title: Row(
								children: [
									Icon(Icons.home),
									SizedBox(
										width: 10,
									),
									Text('Home')
								],
							),
							onTap: () {},
						),
						ListTile(
							title: Row(
								children: [
									Icon(Icons.delete),
									SizedBox(
										width: 10,
									),
									Text('Trash')
								],
							),
							onTap: () {},
						),
						ListTile(
							title: Row(
								children: [
									Icon(Icons.restore),
									SizedBox(
										width: 10,
									),
									Text('Backups')
								],
							),
							onTap: () {},
						),

						Divider(),
						Spacer(),
						ListTile(
							title: const Text('Donate'),
							onTap: () {},
						),
					],
				),
			),

			body: Container(
				height: double.infinity,	
				width: double.infinity,
				color: COLOR_BACKGROUND,
				child: GridView.builder(
					primary: false,
					padding: const EdgeInsets.all(20),
					itemCount: menuData.length,
					gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
						crossAxisCount: 2,
						childAspectRatio: 1.0,
					),
					itemBuilder: (context, index) {
						MenuEntry childData = menuData.getMenuContainer(index);
						
						late Widget childWidget;
						if (childData is EntryPanel) {
							childWidget = PanelIcon(panelMenu: childData);
						} else if (childData is EntryDirectory){
							childWidget = DirIcon(entry: childData);
						}

						return GestureDetector(
							onTap: () {
								if (menuData.mode == GlobalSelectionMode.view) {
									if (childData is EntryPanel) {
										Navigator.of(context).push(
											MaterialPageRoute(
												builder: (context) => EditorPage(initialPage: childData.panel),
											),
										).then((value) => setState(() {}));
									}
								} else {
									setState(() {
										menuData.toggleSelection(index);
									});
								}
							},
							onLongPress: () {
								setState(() {
									menuData.select(index);
								});
							},
							child: childWidget,
						);
					},
				),
			),
			
			bottomNavigationBar: BottomAppBar(
				color: COLOR_MENU_BG,
				child: Row(children: [
					IconButton(
						icon: const Icon(Icons.note_add),
						tooltip: 'New Note',
						onPressed: () {
							newNote();
						},
					),
					IconButton(
						icon: const Icon(Icons.create_new_folder_sharp),
						tooltip: 'New Folder',
						onPressed: () {
							newDir();
						},
					),
					Spacer(),
					IconButton(
						icon: const Icon(Icons.more_vert),
						tooltip: 'More options',
						onPressed: () {},
					),
				]),
			),
		);
	}

	// IO functions
	Future<String> get _localPath async {
		final directory = await getApplicationDocumentsDirectory();
		return directory.path;
	}

	Future<Directory> _getLocalDir() async {
		final path = await _localPath;
		return Directory('$path/note_panels').create(recursive: true);
	}

	Future<void> readFiles() async {
		try {
			final dir = await _getLocalDir();
			final entities = await dir.list().toList();
			final Iterable<Directory> dirs = entities.whereType<Directory>();
			final Iterable<File> files = entities.whereType<File>();

			for (var d in dirs) {
				menuData.addDir(d);
			}

			for (var f in files) {
				PanelData.fromFile(f).then((pd) {
					setState(() {
						menuData.add(pd);
					});
				});
			}
		} catch (e) {}
	}

	Future<void> newNote() async {
		final path = await _localPath;
		final name = "panel" + DateTime.now().millisecondsSinceEpoch.toString() + ".json";
		final filename = '$path/note_panels/$name';
		var file =  await File(filename);
		PanelData.newWithFile(file).then((pd) {
			setState(() {
				menuData.add(pd);
			});
		});
	}
	
	Future<void> newDir() async {
		final path = await _localPath;
		final name = "dir" + DateTime.now().millisecondsSinceEpoch.toString();
		final filename = '$path/note_panels/$name';
		var dir =  await Directory(filename).create();
		setState(() {
			menuData.addDir(dir);
		});
	}

	/// Delete all of the currently selected notes
	Future<void> deleteSelected() async {
		var removed = menuData.removeSelected();
		for (var entry in removed) {
			try {
				await entry.deleteFile();
			} catch (e) {}
		}
	}

}
