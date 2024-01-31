import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:panels/panel_visualizer.dart';
import 'package:panels/user_widget.dart';

import 'main.dart';

class UWFormFactory extends UWFactory<UWForm> {
	static final String id = 'form';

	String text = "";

	UWFormFactory(Key key) : super(key);

	@override
	UWForm build(PanelVisualizerState page, Mode mode, bool selected) {
		return UWForm(page, mode, this, selected, key);
	}
	
	@override	
	String previewString() {
		return text;
	}
	
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

class UWForm extends UserWidget{
	final UWFormFactory factory;
	final bool selected;

  UWForm(super.widgetController, super.mode, this.factory, this.selected, Key key) : super(key: key);

	@override
	State<StatefulWidget> createState() => _UWFormState();
}

class _UWFormState extends State<UWForm> {
	TextEditingController _textController = TextEditingController();

	@override
	void initState() {
		super.initState();
		_textController.text = widget.factory.text;
	}

	@override
	Widget build(BuildContext context) {
		TextField field = TextField(
			decoration: InputDecoration(
				hintText: 'This is a form!',
			),
			controller: _textController,
			onChanged: (value) {
			  widget.factory.text = value;
				widget.controller.requestSave();
			},
		);

		var content = Row(
			children: [
				Expanded(
					child:field,
				),
				IconButton(
					icon: Icon(Icons.copy),
					onPressed: () async {
						var controller = field.controller;
						if (controller != null) {
							await Clipboard.setData(ClipboardData(text: controller.text));
						}
					},
				),
			],
		);

		if (widget.mode == Mode.view) {
			return Container(
				padding: EdgeInsets.only(left: 15, right: 9, top: 3, bottom: 3),
				decoration: BoxDecoration(
					color: COLOR_BACKGROUND_MID,
					//border: Border.all(
					//	width: 0.1,
					//),
					borderRadius: BorderRadius.circular(3),
				),
				child: content,
			);
		}
			return Container(
				padding: EdgeInsets.only(left: 14, right: 8, top: 2, bottom: 2),
				decoration: BoxDecoration(
					color: widget.selected ? COLOR_BACKGROUND_HEAVY : COLOR_BACKGROUND_MID,
					border: Border.all(
						width: 1,
					),
					borderRadius: BorderRadius.circular(3),
				),
				child: content,
			);
		}
	
	@override
	void dispose() {
		_textController.dispose();
		super.dispose();
	}
}