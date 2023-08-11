import 'package:flutter/material.dart';
import 'package:panels/panel_controller.dart';
import 'package:panels/user_widget.dart';

import 'panel_page.dart';
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
	UWCheckFactory(Key key) : super(key);

	@override
	UserWidget build(PanelControllerState page, Mode mode) {
		return UWCheck(page, mode, key);
	}
}

class UWCheck extends UserWidget {
  UWCheck(super.widgetController, super.mode, Key key) : super(key: key);

	@override
	State<StatefulWidget> createState() => _UWCheckState();
}

class _UWCheckState extends State<UWCheck> {
	TextEditingController _controller = TextEditingController();

	@override
	Widget build(BuildContext context) {
		PersistentCheck box = PersistentCheck();
		TextField field = TextField(
			//enabled: widget.mode == Mode.view,
			decoration: InputDecoration(
				border: InputBorder.none,
				hintText: 'Enter a to-do',
			),
			controller: _controller,
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
				child: Row(children: [box, Expanded(child: field)]),
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
					box,
					Expanded(child: field),
					IconButton(
						icon: Icon(Icons.delete),
						onPressed: () {
							widget.controller.remove(widget.key!);
						},
					),
					//IconButton(onPressed: (){}, icon: Icon(Icons.done)),
					IconButton(
						icon: Icon(Icons.add_task),
						onPressed: (){
							widget.controller.insertAfter(widget.key!, UWCheckFactory(GlobalKey()));
						},
					),
				],
			),
		);
	}
}