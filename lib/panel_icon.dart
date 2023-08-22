import 'package:flutter/material.dart';
import 'package:panels/main.dart';
import 'package:panels/panel_data.dart';

import 'editor_page.dart';

/// The widget that represents a specifc NotePanel on the main page
class PanelIcon extends StatelessWidget {
	final PanelData initialPage;
	final void Function() refreshCallback;
	
	PanelIcon({required this.initialPage, required this.refreshCallback});

	@override
	Widget build(BuildContext context) {
		return GestureDetector(
			onTap: () {
				Navigator.of(context).push(
					MaterialPageRoute(
						builder: (context) => EditorPage(initialPage: initialPage)
					),
				).then((value) => refreshCallback());
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
						Text(
							initialPage.title,
							style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
						Expanded(
							child: Text(initialPage.getPreview(),
							),
						),
					],
				),
			),
		);
	}
}