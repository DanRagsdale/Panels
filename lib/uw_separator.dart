import 'package:flutter/material.dart';

import 'second_page.dart';

class UWSeparator extends StatelessWidget {
	UWSeparator({required this.mode});

	final Mode mode;

	@override
	Widget build(BuildContext context) {
		List<Widget> items = [
		    Expanded(
					child: Container(
		    	padding: const EdgeInsets.all(8),
		    	color: Colors.black,
		    	height: 6.0,
		    ),
			),
		];
		if (mode == Mode.edit) {
			items.add(IconButton(onPressed: (){print("Deleting!");}, icon: Icon(Icons.delete_outline)));
		}

		return Row(
		  children: items,
		);
	}
}