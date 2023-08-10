import 'package:flutter/material.dart';
import 'package:panels/user_widget.dart';

import 'PanelPage.dart';
import 'main.dart';
import 'editor_page.dart';

class UWTextFactory extends UserWidgetFactory {
	UWTextFactory(Key key) : super(key);

	@override
	UserWidget build(PanelControllerState widgetController, Mode mode) {
		return UWText(widgetController, mode, key);
	}
}

class UWText extends UserWidget{
  UWText(super.widgetController, super.mode, Key key) : super(key: key);

	@override
	State<StatefulWidget> createState() => _UWTextState();
}

class _UWTextState extends State<UWText> {
	TextEditingController _controller = TextEditingController();

	@override
	Widget build(BuildContext context) {
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

		if (widget.mode == Mode.view) {
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
							IconButton(onPressed: (){widget.controller.remove(widget.key!);}, icon: Icon(Icons.delete)),
							//IconButton(onPressed: (){}, icon: Icon(Icons.done)),
							IconButton(onPressed: (){widget.controller.insertAfter(widget.key!, UWTextFactory(GlobalKey()));}, icon: Icon(Icons.add_task)),
						],
					),
			    field,
			  ],
			),
		);
	}
}