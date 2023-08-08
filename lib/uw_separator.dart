import 'package:flutter/material.dart';
import 'package:panels/user_widget.dart';

import 'second_page.dart';

class UWSeparator extends UserWidget{
	UWSeparator(UWDisplayState wc) : super(wc);

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
						print("Deleting!");
						widgetController.remove(this);
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