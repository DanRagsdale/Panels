import 'package:flutter/material.dart';
import 'package:panels/main.dart';

import 'second_page.dart';

class NoteIcon extends StatelessWidget {
	NoteIcon({required this.title, required this.preview});

	final String title;
	final String preview;
	
	@override
	Widget build(BuildContext context) {
		return GestureDetector(
			onTap: () {
				Navigator.of(context).push(
					MaterialPageRoute(
						builder: (context) => SecondPage(this.title)
					),
				);
			},
			child: Container(
				padding: const EdgeInsets.all(8),
				decoration: BoxDecoration(
					color: COLOR_BACKGROUND_HEAVY,
					border: Border.all(
						width: 4,
					),
					borderRadius: BorderRadius.circular(12),
				),
				child: Column(
					children: [
						Text(this.title, style: TextStyle(fontWeight: FontWeight.bold)),
						Text(this.preview),
					],
				),
			),
		);
	}
}