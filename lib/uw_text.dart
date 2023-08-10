import 'package:flutter/material.dart';
import 'package:panels/user_widget.dart';

import 'main.dart';
import 'editor_page.dart';

class UWTextFactory extends UserWidgetFactory {
	@override
	UserWidget build(PanelControllerState widgetController, {Key? key}) {
		return UWText(widgetController, key: key);
	}
}

class UWText extends UserWidget{
	UWText(PanelControllerState wc, {Key? key}) : super(wc, key: key);

	TextEditingController _controller = TextEditingController();

	@override
	Widget build(BuildContext context, Mode mode) {
		TextField field = TextField(
			decoration: InputDecoration(
				border: InputBorder.none,
				hintText: 'What is on your mind?',
			),
			keyboardType: TextInputType.multiline,
			controller: _controller,
			style: TextStyle(fontWeight: FontWeight.bold),
			minLines: 1,
			maxLines: 1024,
		);

		if (mode == Mode.view) {
			return Container(
				key: key,
				padding: EdgeInsets.all(3),
				decoration: BoxDecoration(
					color: COLOR_BACKGROUND_MID,
					//border: Border.all(
					//	width: 0.1,
					//),
					borderRadius: BorderRadius.circular(3),
				),
				child: field,
			);
		}
		
		return Container(
			key: key,
			padding: EdgeInsets.all(3),
			decoration: BoxDecoration(
				color: COLOR_BACKGROUND_MID,
				border: Border.all(
					width: 1,
				),
				borderRadius: BorderRadius.circular(3),
			),

			child: Column(
			  children: [
					Row(
						mainAxisAlignment: MainAxisAlignment.end,
						children: [
							IconButton(onPressed: (){widgetController.remove(this);}, icon: Icon(Icons.delete)),
							//IconButton(onPressed: (){}, icon: Icon(Icons.done)),
							IconButton(onPressed: (){widgetController.insertAfter(this, UWText(widgetController, key: widgetController.getKey()));}, icon: Icon(Icons.add_task)),
						],
					),
			    field,
			  ],
			),
		);
	}
}