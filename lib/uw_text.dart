import 'package:flutter/material.dart';
import 'package:panels/panel_visualizer.dart';
import 'package:panels/user_widget.dart';

import 'main.dart';

class UWTextFactory extends UWFactory<UWText> {
	static final String id = 'text';

	String text = "";

	UWTextFactory(Key key) : super(key);

	@override
	UWText build(PanelVisualizerState page, Mode mode, bool selected) {
		return UWText(page, mode, this, selected, key);
	}
	
	@override	
	String previewString() => text;
	
	@override
	Map toJsonMap() {
		return {
			'id' : id,
			'body' : text,
		};
	}

	@override
	void buildFromJsonMap(Map m) {
		text = m['body'];
	}
}

class UWText extends UserWidget{
	final UWTextFactory factory;
	final bool selected;

  UWText(super.widgetController, super.mode, this.factory, this.selected, Key key) : super(key: key);

	@override
	State<StatefulWidget> createState() => _UWTextState();
}

class _UWTextState extends State<UWText> {
	TextEditingController _textController = TextEditingController();

	@override
	void initState() {
		_textController.text = widget.factory.text;
		super.initState();
	}

	@override
	Widget build(BuildContext context) {
		TextField field = TextField(
			//enabled: widget.mode == Mode.view,
			decoration: InputDecoration(
				border: InputBorder.none,
				hintText: 'What is on your mind?',
			),
			keyboardType: TextInputType.multiline,
			controller: _textController,
			style: TextStyle(fontWeight: FontWeight.bold),
			minLines: 1,
			maxLines: 1024,
			onChanged: (value) {
			  widget.factory.text = value;
				widget.controller.requestSave();
			},
		);

		// View Mode display	
		if (widget.mode == Mode.view) {
			return Container(
				padding: EdgeInsets.only(left: 15, right: 4, top: 3, bottom: 3),
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

		// Edit Mode display	
		return Container(
			padding: EdgeInsets.only(left: 14, right: 3, top: 2, bottom: 2),
			decoration: BoxDecoration(
				color: widget.selected ? COLOR_BACKGROUND_HEAVY : COLOR_BACKGROUND_MID,
				border: Border.all(
					width: 1,
				),
				borderRadius: BorderRadius.circular(3),
			),

			child: Stack(
				children: [
					field,
					Positioned(
						right: 0,
						child: IconButton(
							icon: Icon(Icons.add_task),
							onPressed: (){
								widget.controller.insertAfter(widget.key!, UWTextFactory(GlobalKey()));
							},
						),
					)
				],
			),
			//Column(
			//  children: [
			//    field,
			//  ],
			//),
		);
	}
	
	@override
	void dispose() {
		_textController.dispose();
		super.dispose();
	}
}