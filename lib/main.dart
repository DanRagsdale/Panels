import 'package:flutter/material.dart';
import 'package:panels/panel_data.dart';
import 'package:panels/uw_check.dart';
import 'package:panels/uw_separator.dart';

import 'panel_icon.dart';

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
	List<PanelData> panels = [
		PanelData("Example", [UWCheckFactory(GlobalKey()), UWSeparatorFactory(GlobalKey())]),
		PanelData("Empty 1", []),
		PanelData("Empty 2", []),
	];

	void refreshCallback() {
		setState(() {});
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text("Panels"),
				foregroundColor: COLOR_TEXT,
				backgroundColor: COLOR_MENU_BG,
			),
			body: Container(
				height: double.infinity,	
				width: double.infinity,
				color: COLOR_BACKGROUND,
				child: GridView.count(
					primary: false,
					padding: const EdgeInsets.all(20),
					crossAxisSpacing: 10,
					mainAxisSpacing: 10,
					crossAxisCount: 2,
					children: panels.map((e) => PanelIcon(initialPage: e, refreshCallback: refreshCallback,)).toList(),
					//],
				),
			),
			bottomNavigationBar: BottomAppBar(
				color: COLOR_MENU_BG,
				child: Row(children: [
					IconButton(
						icon: const Icon(Icons.note_add),
						tooltip: 'New Note',
						onPressed: () {},
					),
					IconButton(
						icon: const Icon(Icons.create_new_folder_sharp),
						tooltip: 'New Folder',
						onPressed: () {},
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
}
