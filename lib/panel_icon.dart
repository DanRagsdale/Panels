import 'package:flutter/material.dart';
import 'package:panels/main.dart';

/// The widget that represents a specifc NotePanel on the main page
class PanelIcon extends StatelessWidget {
	final PanelMenuContainer panelMenu;
	
	PanelIcon({required this.panelMenu});

	@override
	Widget build(BuildContext context) {
		return Container(
			margin: const EdgeInsets.all(4),
			padding: const EdgeInsets.all(8),
			decoration: BoxDecoration(
				color: panelMenu.mode == LocalSelectionMode.selected ? Colors.white : COLOR_BACKGROUND_HEAVY,
				border: Border.all(
					width: 4,
				),
				borderRadius: BorderRadius.circular(12),
			),
			child: Column(
				children: [
					Text(
						panelMenu.panel.title,
						style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
					Expanded(
						child: Text(panelMenu.panel.getPreview(),
						),
					),
				],
			),
		);
	}
}