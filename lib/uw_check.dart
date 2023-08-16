import 'package:flutter/material.dart';
import 'package:panels/panel_controller.dart';
import 'package:panels/user_widget.dart';

import 'panel_page.dart';
import 'main.dart';
import 'editor_page.dart';

class UWCheckFactory extends UserWidgetFactory {
	UWCheckFactory(Key key) : super(key);

	@override
	UserWidget build(PanelControllerState page, Mode mode) {
		return UWCheck(page, mode, key);
	}

	@override	
	String previewString() {
		return "Checkbox";
	}
}

class UWCheck extends UserWidget {
  UWCheck(super.widgetController, super.mode, Key key) : super(key: key);

	@override
	State<StatefulWidget> createState() => _UWCheckState();
}

class _UWCheckState extends State<UWCheck> {
	TextEditingController _textController = TextEditingController();
	bool checkState = false;

	@override
	Widget build(BuildContext context) {
		Checkbox box = Checkbox(
 			value: checkState,
			onChanged: (bool? value) { 
				setState(() {
					checkState = value!;
				});
			},
		);
		TextField field = TextField(
			//enabled: widget.mode == Mode.view,
			decoration: InputDecoration(
				border: InputBorder.none,
				hintText: 'Enter a to-do',
			),
			controller: _textController,
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
	
	@override
	void dispose() {
		_textController.dispose();
		super.dispose();
	}
}