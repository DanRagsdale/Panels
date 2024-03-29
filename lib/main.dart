import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:panels/menu_icon_dir.dart';
import 'package:panels/panel_visualizer.dart';
import 'package:panels/user_widget.dart';
import 'package:panels/uw_text.dart';

import 'package:panels/panel_data.dart';

import 'io_tools.dart';
import 'menu_icon_panel.dart';
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
			home: MainPage(dirType: DirType.home,),
		);
	}
}

enum DirType {
	home, trash, general,
}

class MainPage extends StatefulWidget {
	final DirContainer? directory;
	final DirType dirType;

	MainPage({required this.dirType, this.directory,});

	@override
	State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
	late SelectionMenuData menuData;
	
	late DirType dirType;
	DirContainer? _activeDir;	

	@override
	void initState() {
		super.initState();
		dirType = widget.dirType;
		_activeDir = widget.directory;
		readFiles();
		readConfig();
	}

	TextEditingController _titleController = TextEditingController();

	@override
	Widget build(BuildContext context) {
		// TODO undo functions when deleting
	
		// Widgets
		AppBar topBar = buildTopBar();
		Drawer? drawer = buildDrawer();
		BottomAppBar? bottomBar = buildBottomBar();

		return Scaffold(
			appBar: topBar,
			drawer: drawer,
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
												builder: (context) => PanelVisualizer(initialPage: childData.panel),
											),
										).then((value) {
												setState(() {
													menuData.sort();
												});
										});
									} else if (childData is EntryDirectory) {
										Navigator.of(context).push(
											MaterialPageRoute(
												builder: (context) => MainPage(dirType: DirType.general, directory: childData.dir),
											),
										).then((value) {
											readFiles();
											readConfig();
										}); // User may have moved files or changed config, necessitating a full rebuild
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
			
			bottomNavigationBar: bottomBar,
		);
	}

	AppBar buildTopBar() {
		if (menuData.mode == GlobalSelectionMode.view) {
			switch(dirType) {
				case DirType.home:
					return AppBar(
						foregroundColor: COLOR_TEXT,
						backgroundColor: COLOR_MENU_BG,
						title: const Text("Panels"),
					);
				case DirType.trash:
					return AppBar(
						foregroundColor: COLOR_TEXT,
						backgroundColor: COLOR_MENU_BG,
						title: const Text("Trash"),
					);
				case DirType.general:
					_titleController.text = _activeDir!.displayName;
					return AppBar(
						foregroundColor: COLOR_TEXT,
						backgroundColor: COLOR_MENU_BG,
						title: TextField(
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
							},
						),
					);
			}
		} else {
			return AppBar(
				foregroundColor: COLOR_TEXT,
				backgroundColor: COLOR_MENU_BG,
				leading: IconButton(
					icon: Icon(Icons.close_outlined),
					onPressed: () {
						setState(() {
							menuData.deselectAll();
						});
					},
				),
				title: Text("${menuData.selectedCount} Selected"),
				actions: [
					// Move Files
					IconButton(
						icon: Icon(Icons.move_up_outlined),
						onPressed: () {
							if (menuData.selectedCount == 0) {
								return;
							}
							MenuMove menuMove = MenuMove(menuData);
							showDialog<DirContainer?>(
								context: context,
								builder: (BuildContext context) => Dialog(
									insetPadding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 24.0),
									child: menuMove,
								),
							).then((value) async {
								if (value != null && value.path != _activeDir?.path) {
									List<MenuEntry> selections = menuData.removeSelected();
									setState(() {});
									for (var s in selections) {
										try {
											await s.moveTo(value.path);
										} catch(e) {
										}
									}
								}
							});
						},
					),
					// Delete Files
					IconButton(
						icon: Icon(Icons.delete),
						onPressed: () {
							deleteSelected().then((_) {
								setState(() {});
							});
						},
					),
				],
			);
		}

	}

	Drawer? buildDrawer() {
			if (menuData.mode == GlobalSelectionMode.view && dirType == DirType.home) {
				return Drawer(
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
										Icon(Icons.delete),
										SizedBox(
											width: 10,
										),
										Text('Trash')
									],
								),
								onTap: () {
									getTrashDir().then((dir) {
										Navigator.of(context).push(
											MaterialPageRoute(
												builder: (context) => MainPage(dirType: DirType.trash, directory: dir),
											),
										).then((value) {
											readFiles();
											readConfig();
										}); // User may have moved files or changed config, necessitating a full rebuild
									});
								},
							),
							//ListTile(
							//	title: Row(
							//		children: [
							//			Icon(Icons.restore),
							//			SizedBox(
							//				width: 10,
							//			),
							//			Text('Backups')
							//		],
							//	),
							//	onTap: () {},
							//),

							Divider(),
							Spacer(),
							ListTile(
								title: const Text('Support Panels'),
								subtitle: const Text('Venmo: DanRagsdale'),
								onTap: null,
							),
						],
					),
				);
			}
			return null;
	}

	BottomAppBar? buildBottomBar() {
		if(dirType == DirType.trash) {
			return null;
		}

		return BottomAppBar(
			color: COLOR_MENU_BG,
			child: Row(
				children: [
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
					PopupMenuButton(
						icon: Icon(Icons.more_vert),
						tooltip: "Sort",
						offset: Offset(0.0, -120.0),

						itemBuilder: (context) => [
							PopupMenuItem( 
								value: 0,
								onTap: () => {
									setState(() {
										menuData.sortReversed = !menuData.sortReversed;
										menuData.sort();
									})
								},
								child: Row(
									children: [
										Icon(menuData.sortReversed ? Icons.arrow_upward_outlined : Icons.arrow_downward_outlined),
										SizedBox(
											width: 10,
										),
										Text("Sort Direction")
									],
								),
							),
							PopupMenuItem( 
								value: 0,
								onTap: () => {
									setState(() {
										menuData.sortMode = SortMode.alphabetical;
										menuData.sort();
									})
								},
								child: Row(
									children: [
										Icon(Icons.abc),
										SizedBox(
											width: 10,
										),
										Text("Alphabetical")
									],
								),
							),
						],
						onSelected: (_value) {
							saveConfig();
						},
					),
				],
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
	Future<DirContainer> _getActiveDir() async {
		if (_activeDir == null) {
			_activeDir = await getMainDir();
		}
		return _activeDir!;
	}

	// File IO functions
	
	Future<void> readConfig() async {
		try {
			final dirCon = await getConfigDir();
			File f = File(dirCon.path + "/config.json");
			if (await f.exists()) {
				print("Config Found!!");
				final rawContents = await f.readAsString();
				final contents = jsonDecode(rawContents);

				print(contents);

				menuData.sortReversed = contents["sort_reversed"];
				menuData.sortMode = SortMode.values[contents["sort_mode"]];

				setState(() {
					menuData.sort();
				});
			} else {
				print("Config not found!!!");
			}
		} catch (e) {}
	}

	Future<void> saveConfig() async {
		print("Saving Config!");
		final dirCon = await getConfigDir();
		File file = File(dirCon.path + "/config.json");
		//var widgetMaps = [];
		//for (var w in widgetEntries) {
		//	widgetMaps.add(w.uw.toJsonMap());
		//}
		//// Write the file
		var output = jsonEncode({
			"sort_reversed" : menuData.sortReversed,
			"sort_mode" : menuData.sortMode.index,
		});

		file.writeAsString(output);
	}

	/// Read the files and folders in the active directory, and add them to the menuData object
	Future<void> readFiles() async {
		setState(() {
			menuData = SelectionMenuData();
		});
		try {
			final dirCon = await _getActiveDir();
			final entities = await dirCon.dir.list().toList();
			final Iterable<Directory> dirs = entities.whereType<Directory>();
			final Iterable<File> files = entities.whereType<File>();

			for (var d in dirs) {
					menuData.addDir(DirContainer(d));
			}

			for (var f in files) {
				PanelData pd = await PanelData.fromFile(f);
				menuData.addPanel(pd);
			}

			setState(() {
			  menuData.sort();
			});

		} catch (e) {}
	}

	/// Create a new note in the active directory
	Future<void> newNote({List<UWFactory> factories = const []}) async {
		DirContainer dir = await _getActiveDir();
		final name = "panel" + DateTime.now().millisecondsSinceEpoch.toString() + ".json";
		final filename = '${dir.path}/$name';
		var file =  await File(filename);
		PanelData.newWithFile(file: file, factories: factories).then((pd) {
			setState(() {
				menuData.addPanel(pd);
				menuData.sort();
			});
		});
	}
	
	/// Create a new folder in the active directory
	Future<void> newDir() async {
		DirContainer dir = await _getActiveDir();
		final name = "dir" + DateTime.now().millisecondsSinceEpoch.toString() + "-*-" + DEFAULT_FOLDER_TITLE;
		final filename = '${dir.path}/$name';
		var newDir =  await Directory(filename).create();
		setState(() {
			menuData.addDir(DirContainer(newDir));
			menuData.sort();
		});
	}

	/// Move the selected files to the trash
	/// If the user is selecting files from the trash, the file is permanenetly deleted
	Future<void> deleteSelected() async {
		if (dirType != DirType.trash) {
			var trashDir = await getTrashDir();
			List<MenuEntry> selections = menuData.removeSelected();
			setState(() {});
			for (var s in selections) {
				try {
					await s.moveTo(trashDir.path);
				} catch(e) {
				}
			}
			return;
		}
		var removed = menuData.removeSelected();
		for (var entry in removed) {
			try {
				await entry.deleteFile();
			} catch (e) {}
		}
	}
}
