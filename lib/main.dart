import 'package:flutter/material.dart';

import 'second_page.dart';

const Color COLOR_TEXT = Colors.black;
//const Color COLOR_MENU_TEXT = Color(0xff2E272D);
const Color COLOR_BACKGROUND = Color(0xffEDF6F9);
const Color COLOR_MENU = Color(0xffFFDDD2);

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
				backgroundColor: COLOR_MENU,
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
						Container(
							padding: const EdgeInsets.all(8),
							decoration: BoxDecoration(
								color: const Color(0xff7c94b6),
								border: Border.all(
									width: 8,
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
						Container(
							padding: const EdgeInsets.all(8),
							color: Colors.teal[200],
							child: const Text('Heed not the rabble'),
						),
					],
				),
				//ElevatedButton(
				//	onPressed: () {
				//		Navigator.of(context).push(
				//						MaterialPageRoute(
				//							builder: (BuildContext context) {
				//								return SecondPage();
				//							},
				//						),
				//					);
				//	},
				//	child: const Text("Button"),
				//),
			),
			bottomNavigationBar: BottomAppBar(
				color: COLOR_MENU,
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
