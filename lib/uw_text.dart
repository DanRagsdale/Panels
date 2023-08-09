import 'package:flutter/material.dart';
import 'package:panels/user_widget.dart';

import 'main.dart';
import 'second_page.dart';

class UWText extends UserWidget{
	UWText(UWControllerState wc) : super(wc);

	TextEditingController _controller = TextEditingController(text: "Test\nText");

	@override
	Widget build(BuildContext context, Mode mode) {

		TextField field = TextField(
			decoration: null,
			keyboardType: TextInputType.multiline,
			controller: _controller,
			style: TextStyle(fontWeight: FontWeight.bold),
			minLines: 1,
			maxLines: 1024,
		);

		if (mode == Mode.view) {
			return Container(
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
							IconButton(onPressed: (){}, icon: Icon(Icons.done)),
							IconButton(onPressed: (){widgetController.insertAfter(this, UWText(widgetController));}, icon: Icon(Icons.add_task)),
						],
					),
			    field,
			  ],
			),
		);
	}
}