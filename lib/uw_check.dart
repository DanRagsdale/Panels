import 'package:flutter/material.dart';
import 'package:panels/user_widget.dart';

import 'main.dart';
import 'second_page.dart';

class UWCheck extends UserWidget {
	TextEditingController _controller = TextEditingController(text: "Test Check");

	@override
	Widget build(BuildContext context, Mode mode) {
		CheckboxListTile check = CheckboxListTile(
			title: TextField(
				decoration: null,
				controller: _controller,
			),
			value: true,
			controlAffinity: ListTileControlAffinity.leading,
			onChanged: (_) {},
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
				child: check,
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

			child: Row(
				mainAxisAlignment: MainAxisAlignment.end,
				children: [
					Expanded(child: check),
					IconButton(onPressed: (){}, icon: Icon(Icons.delete)),
					IconButton(onPressed: (){}, icon: Icon(Icons.done)),
					IconButton(onPressed: (){}, icon: Icon(Icons.add_task)),
				],
			),
		);
	}
}