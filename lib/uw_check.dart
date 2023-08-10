import 'package:flutter/material.dart';
import 'package:panels/user_widget.dart';

import 'main.dart';
import 'editor_page.dart';

class PersistentCheck extends StatefulWidget {
	@override
	State<StatefulWidget> createState() => _PersistentCheckState();
}

class _PersistentCheckState extends State<PersistentCheck> {
	bool state = false;
	@override
	Widget build(BuildContext context) {
		return Checkbox(
			value: state,
			onChanged: (val) {
				setState(() {
					state = val!;
				});
			},
		);
	}
}

class UWCheckFactory extends UserWidgetFactory {
	@override
	UserWidget build(PanelControllerState widgetController, {Key? key}) {
		return UWCheck(widgetController, key: key);
	}
}

class UWCheck extends UserWidget {
	TextEditingController _controller = TextEditingController();
	
	UWCheck(PanelControllerState wc, {Key? key}) : super(wc, key: key);

	@override
	Widget build(BuildContext context, Mode mode) {
		PersistentCheck box = PersistentCheck();
		TextField field = TextField(
				decoration: InputDecoration(
					border: InputBorder.none,
					hintText: 'Enter a to-do',
				),
				controller: _controller,
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
				child: Row(children: [box, Expanded(child: field)]),
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

			child: Row(
				mainAxisAlignment: MainAxisAlignment.end,
				children: [
					box,
					Expanded(child: field),
					IconButton(onPressed: (){widgetController.remove(this);}, icon: Icon(Icons.delete)),
					//IconButton(onPressed: (){}, icon: Icon(Icons.done)),
					IconButton(onPressed: (){widgetController.insertAfter(this, UWCheck(widgetController, key: widgetController.getKey()));}, icon: Icon(Icons.add_task)),
				],
			),
		);
	}
}