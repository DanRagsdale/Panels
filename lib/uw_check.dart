import 'package:flutter/material.dart';
import 'package:panels/panel_visualizer.dart';
import 'package:panels/user_widget.dart';
import 'package:panels/uw_check_controller.dart';

import 'main.dart';

class UWCheckFactory extends UWFactory<UWCheck> {
	static final String id = 'check';

	bool state = false;
	String text = "";
	
	UWCheckFactory(Key key) : super(key);

	@override
	UWCheck build(PanelVisualizerState page, Mode mode, bool selected) {
		return UWCheck(page, mode, this, selected, key);
	}

	@override	
	String previewString() {
		var boxSymbol = state ? '☑' : '☐';
		return "$boxSymbol-$text";
	}

	@override
	bool receiveMessage(WidgetMessage message) {
		if (message is MessageUncheck) {
			state = false;
			return true;
		}
		return false;
	}
	
	@override
	Map toJsonMap() {
		return {
			'id' : id,

			'state' : state,
			'body' : text,
		};
	}

	@override
	void buildFromJsonMap(Map m) {
		state = m['state'];
		text = m['body'];
	}
}

class UWCheck extends UserWidget {
	final UWCheckFactory factory;
	final bool selected;

  UWCheck(super.widgetController, super.mode, this.factory, this.selected, Key key) : super(key: key);

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
			fillColor: MaterialStateColor.resolveWith((states) => COLOR_MENU_COLD),
 			value: widget.factory.state,
			onChanged: (bool? value) { 
				setState(() {
					widget.factory.state = value!;
				});
				widget.controller.requestSave();
			},
		);
		TextField field = TextField(
			//enabled: widget.mode == Mode.view,
			decoration: InputDecoration(
				border: InputBorder.none,
				hintText: 'Enter a to-do',
			),
			textInputAction: TextInputAction.newline,
			controller: _textController,
			onChanged: (value) {
			  widget.factory.text = value;
				widget.controller.requestSave();
			},
			onSubmitted: (value) {
				widget.controller.insertAfter(widget.key!, UWCheckFactory(GlobalKey()));
			},
		);
		
		if (widget.mode == Mode.view) {
			return Container(
				padding: EdgeInsets.all(4),
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
				color: widget.selected ? COLOR_BACKGROUND_HEAVY : COLOR_BACKGROUND_MID,
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