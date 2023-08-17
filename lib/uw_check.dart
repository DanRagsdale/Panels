import 'package:flutter/material.dart';
import 'package:panels/panel_controller.dart';
import 'package:panels/user_widget.dart';

import 'panel_page.dart';
import 'main.dart';
import 'editor_page.dart';

class UWCheckFactory extends UWFactory<UWCheck> {
	bool state = false;
	String text = "";
	
	UWCheckFactory(Key key) : super(key);

	@override
	UWCheck build(PanelControllerState page, Mode mode) {
		return UWCheck(page, mode, this, key);
	}

	@override	
	String previewString() {
		return "Checkbox";
	}
}

class UWCheck extends UserWidget {
	final UWCheckFactory factory;

  UWCheck(super.widgetController, super.mode, this.factory, Key key) : super(key: key);

	@override
	State<StatefulWidget> createState() => _UWCheckState();
}

class _UWCheckState extends State<UWCheck> {
	TextEditingController _textController = TextEditingController();

	@override
	void initState() {
		_textController.text = widget.factory.text;
		super.initState();
	}

	@override
	Widget build(BuildContext context) {
		Checkbox box = Checkbox(
 			value: widget.factory.state,
			onChanged: (bool? value) { 
				setState(() {
					widget.factory.state = value!;
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
			onChanged: (value) {
			  widget.factory.text = value;
			},
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