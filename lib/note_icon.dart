import 'package:flutter/material.dart';

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
					color: const Color(0xff7c94b6),
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