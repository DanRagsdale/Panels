import 'package:flutter/material.dart';
import 'package:panels/panel_controller.dart';
import 'package:panels/user_widget.dart';

import 'panel_page.dart';
import 'editor_page.dart';

class UWSeparatorFactory extends UserWidgetFactory {
	UWSeparatorFactory(Key key) : super(key);

	@override
	UserWidget build(PanelControllerState page, Mode mode) {
		return UWSeparator(page, mode, key);
	}
	
	@override	
	String previewString() => "Separator";
}

class UWSeparator extends UserWidget{
  UWSeparator(super.widgetController, super.mode, Key key) : super(key: key);

	@override
	State<UWSeparator> createState() => _UWSeparatorState();
}

class _UWSeparatorState extends State<UWSeparator> {
	@override
	Widget build(BuildContext context) {
		List<Widget> items = [
			Expanded(
				child: Container(
					margin: const EdgeInsets.all(8),
					color: Colors.black,
					height: 6.0,
				),
			),
		];
		if (widget.mode == Mode.edit) {
			items.add(
				IconButton(
					icon: Icon(Icons.delete),
					onPressed: () {
						setState(() => widget.controller.remove(widget.key!));
					},
				),
			);
		}

		return Row(
			children: items,
		);
	}
}