import 'package:flutter/material.dart';

import 'second_page.dart';

const Color COLOR_TEXT = Color(0xff000000);
//const Color COLOR_MENU_TEXT = Color(0xff2E272D);
const Color COLOR_BACKGROUND = Color(0xffEDF6F9);

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
		return const MaterialApp(
			//debugShowCheckedModeBanner: false,
			home: FirstPage(),
		);
	}
}

class FirstPage extends StatelessWidget {
	const FirstPage({Key? key}) : super(key: key);

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
					children: <Widget>[
						GestureDetector(
							onTap: () {
								Navigator.of(context).push(
									MaterialPageRoute(
										builder: (context) => SecondPage("Title from 0")
									),
								);
							},
							child: Container(
								padding: const EdgeInsets.all(8),
								decoration: BoxDecoration(
									color: const Color(0xff7c94b6),
									border: Border.all(
										width: 4,
									),
									borderRadius: BorderRadius.circular(12),
								),
								child: Column(
									children: [
										Text("Title", style: TextStyle(fontWeight: FontWeight.bold)),
										const Text("He'd have you all unravel at the, Lorem Ipsum,, Lorem Ipsum,, Lorem Ipsum,   "),
									],
								),
							),
						),

						Container(
							padding: const EdgeInsets.all(8),
							color: Colors.teal[200],
							child: const Text('Heed not the rabble'),
						),
					],
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
