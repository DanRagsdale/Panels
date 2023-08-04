import 'package:flutter/material.dart';

import 'main.dart';
import 'second_page.dart';

class UWText extends StatefulWidget {
	final Mode mode;

	UWText(this.mode, {Key? key}) : super(key: key);

	@override
	State<UWText> createState() => _UWTextState();
}

class _UWTextState extends State<UWText> {
	TextEditingController _controller = TextEditingController(text: "Test\nText");

	@override
	Widget build(BuildContext context) {

		TextField field = TextField(
			decoration: null,
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
							IconButton(onPressed: (){}, icon: Icon(Icons.delete)),
							IconButton(onPressed: (){}, icon: Icon(Icons.done)),
							IconButton(onPressed: (){}, icon: Icon(Icons.add_task)),
						],
					),
			    field,
			  ],
			),
		);
	}
}