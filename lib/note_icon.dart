import 'package:flutter/material.dart';
import 'package:panels/main.dart';
import 'package:panels/panel_page.dart';

import 'editor_page.dart';

class NoteIcon extends StatelessWidget {
	final PanelPage initialPage;
	
	NoteIcon({required this.initialPage});

	@override
	Widget build(BuildContext context) {
		return GestureDetector(
			onTap: () {
				Navigator.of(context).push(
					MaterialPageRoute(
						builder: (context) => EditorPage(initialPage: initialPage)
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
						Text(initialPage.getTitle(), style: TextStyle(fontWeight: FontWeight.bold)),
						Text(initialPage.getPreview()),
					],
				),
			),
		);
	}
}