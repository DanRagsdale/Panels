import 'package:flutter/material.dart';
import 'package:panels/user_widget.dart';

import 'PanelPage.dart';
import 'editor_page.dart';

class UWSeparatorFactory extends UserWidgetFactory {
	UWSeparatorFactory(Key key) : super(key);

	@override
	UserWidget build(PanelControllerState widgetController, Mode mode) {
		return UWSeparator(widgetController, mode, key);
	}
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
					onPressed: (){
						widget.controller.remove(widget.key!);
					},
					icon: Icon(Icons.delete),
				),
			);
		}

		return Row(
			children: items,
		);
	}
}