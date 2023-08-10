import 'package:flutter/material.dart';
import 'package:panels/user_widget.dart';

import 'editor_page.dart';

class UWSeparatorFactory extends UserWidgetFactory {
	@override
	UserWidget build(PanelControllerState widgetController, {Key? key}) {
		return UWSeparator(widgetController, key: key);
	}
}

class UWSeparator extends UserWidget{
	UWSeparator(PanelControllerState wc, {Key? key}) : super(wc, key: key);

	@override
	Widget build(BuildContext context, Mode mode) {
		List<Widget> items = [
			Expanded(
				child: Container(
					margin: const EdgeInsets.all(8),
					color: Colors.black,
					height: 6.0,
				),
			),
		];
		if (mode == Mode.edit) {
			items.add(
				IconButton(
					onPressed: (){
						widgetController.remove(this);
					},
					icon: Icon(Icons.delete),
				),
			);
		}

		return Row(
			key: key,
			children: items,
		);
	}
}