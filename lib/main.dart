import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:panels/menu_icon_dir.dart';
import 'package:panels/user_widget.dart';
import 'package:panels/uw_text.dart';
import 'package:path_provider/path_provider.dart';

import 'package:panels/panel_data.dart';

import 'menu_icon_panel.dart';
import 'editor_page.dart';
import 'main_menu_data.dart';
import 'menu_move.dart';

const Color COLOR_TEXT = Color(0xff000000);
//const Color COLOR_MENU_TEXT = Color(0xff2E272D);
const Color COLOR_BACKGROUND = Color(0xffEDF6F9);
const Color COLOR_BACKGROUND_MID = Color.fromARGB(255, 220, 227, 230);
const Color COLOR_BACKGROUND_HEAVY = Color.fromARGB(255, 157, 164, 197);

const Color COLOR_MENU_BG = Color(0xffFFDDD2);
const Color COLOR_MENU_HOT = Color(0xff4FC5B9);
const Color COLOR_MENU_COLD = Color.fromARGB(255, 2, 81, 88);

const String DEFAULT_NOTE_TITLE = "Untitled Note";
const String DEFAULT_FOLDER_TITLE = "New Folder";

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
	final DirContainer? directory;

	MainPage({this.directory});

	@override
	State<MainPage> createState() => _MainPageState();
}

/// Container holding a reference to a directory
/// Used to allow in place renaming and moving of directories
class DirContainer {
	Directory dir;

	DirContainer(this.dir);

	String get path => dir.path;
	String get fileName => dir.path.split('/').last;
	String get displayName => fileName.split('-*-').last;

	/// Moves the underlying directory to the new name and sets
	/// the directory reference to the new location	
	Future<void> inPlaceRename(String newDispName) async {
		var oldPathList = dir.path.split('/');
		var oldNameList = oldPathList.last.split('-*-');
		
		oldNameList.last = newDispName;

		var newName = oldNameList.join('-*-');
		oldPathList.last = newName;

		var newPath = oldPathList.join('/');

		var newDir = await dir.rename(newPath);
		dir = newDir;
	}
}

class _MainPageState extends State<MainPage> {
	late SelectionMenuData menuData;
	
	DirContainer? _activeDir;	
	bool isHomeDir = true;

	@override
	void initState() {
		super.initState();
		_activeDir = widget.directory;
		isHomeDir = _activeDir == null;
		readFiles();
	}

	TextEditingController _titleController = TextEditingController();

	@override
	Widget build(BuildContext context) {
		// TODO add trash can and undo functions when deleting
	
		// Top toolbar widget
		//TODO properly utilize AppBar Features
		late Widget topBar;
		if (menuData.mode == GlobalSelectionMode.view) {
			if (isHomeDir) {
				topBar = const Text("Panels");
			} else {
				_titleController.text = _activeDir!.displayName;
				topBar = TextField(
					decoration: null,
					controller: _titleController,
					style: TextStyle(fontWeight: FontWeight.bold),
					onTap: () {
						if (_titleController.text == DEFAULT_FOLDER_TITLE) {
							_titleController.text = '';
						}
					},
					onChanged: (value) {
						try {
							_activeDir?.inPlaceRename(value);
						} catch(e) {}
					}
				);
			}
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
					Text("${menuData.selectedCount} Selected"),
					Spacer(),
					IconButton(
						//TODO set up to use the actual 'move item' icon
						icon: Icon(Icons.move_up_outlined),
						onPressed: () {
							MenuMove menuMove = MenuMove(menuData);
							showDialog<DirContainer?>(
								context: context,
								builder: (BuildContext context) => Dialog(
									//contentPadding: EdgeInsets.all(4.0),
									insetPadding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 24.0),
									child: menuMove,
									//title: const Text('Move Files'),
									
									
									//content: menuMove,
								),
							).then((value) async {
								if (value != null && value != _activeDir?.path) {
									List<MenuEntry> selections = menuData.removeSelected();
									setState(() {});
									for (var s in selections) {
										try {
											print(value.path);
											await s.moveTo(value.path);
										} catch(e) {
											print(e.toString());
										}
									}
								}
							});
						},
					),
					IconButton(
						icon: Icon(Icons.delete),
						onPressed: () {
							deleteSelected().then((value) {
								setState(() {});
							});
						},
					),
				],
			);
		}

		return Scaffold(
			appBar: AppBar(
				title: topBar,
				foregroundColor: COLOR_TEXT,
				backgroundColor: COLOR_MENU_BG,
			),

			drawer: (menuData.mode == GlobalSelectionMode.view && isHomeDir) ? Drawer(
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
						//ListTile(
						//	title: Row(
						//		children: [
						//			Icon(Icons.home),
						//			SizedBox(
						//				width: 10,
						//			),
						//			Text('Home')
						//		],
						//	),
						//	onTap: () {},
						//),
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
							title: const Text('Support'),
							onTap: () {},
						),
					],
				),
			) : null,

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
						MenuEntry childData = menuData.getMenuEntry(index);
						
						late Widget childWidget;
						if (childData is EntryPanel) {
							childWidget = MenuIconPanel(panelMenu: childData);
						} else if (childData is EntryDirectory){
							childWidget = MenuIconDir(entry: childData);
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
									} else if (childData is EntryDirectory) {
										Navigator.of(context).push(
											MaterialPageRoute(
												builder: (context) => MainPage(directory: childData.dir),
											),
										).then((value) => readFiles()); // User may have moved files, necessitating a full rebuild
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
							newNote(factories: [UWTextFactory(GlobalKey())]);
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

	@override
	void dispose() {
		super.dispose();
		_titleController.dispose();
	}

	// IO functions
	// Helper Functions
	Future<String> get _localPath async {
		final directory = await getApplicationDocumentsDirectory();
		return directory.path;
	}

	Future<DirContainer> _getActiveDir() async {
		if (_activeDir == null) {
			final path = await _localPath;
			Directory rawDir = await Directory('$path/note_panels').create(recursive: true);
			_activeDir = DirContainer(rawDir);
		}
		return _activeDir!;
	}

	// Main IO functions
	Future<void> readFiles() async {
		setState(() {
			menuData = SelectionMenuData();
		});
		try {
			final dirCon = await _getActiveDir();
			final entities = await dirCon.dir.list().toList();
			final Iterable<Directory> dirs = entities.whereType<Directory>();
			final Iterable<File> files = entities.whereType<File>();

			setState(() {
				for (var d in dirs) {
						menuData.addDir(DirContainer(d));
				}
			});

			for (var f in files) {
				PanelData.fromFile(f).then((pd) {
					setState(() {
						menuData.addPanel(pd);
					});
				});
			}
		} catch (e) {}
	}

	Future<void> newNote({List<UWFactory> factories = const []}) async {
		DirContainer dir = await _getActiveDir();
		final name = "panel" + DateTime.now().millisecondsSinceEpoch.toString() + ".json";
		final filename = '${dir.path}/$name';
		var file =  await File(filename);
		PanelData.newWithFile(file: file, factories: factories).then((pd) {
			setState(() {
				menuData.addPanel(pd);
			});
		});
	}
	
	Future<void> newDir() async {
		DirContainer dir = await _getActiveDir();
		final name = "dir" + DateTime.now().millisecondsSinceEpoch.toString() + "-*-" + DEFAULT_FOLDER_TITLE;
		final filename = '${dir.path}/$name';
		var newDir =  await Directory(filename).create();
		setState(() {
			menuData.addDir(DirContainer(newDir));
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
