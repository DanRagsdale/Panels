import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:panels/panel_visualizer.dart';
import 'package:panels/user_widget.dart';

import 'main.dart';
import 'editor_page.dart';

class UWFormFactory extends UWFactory<UWForm> {
	static final String id = 'form';

	List<String> items = [];

	UWFormFactory(Key key) : super(key);

	@override
	UWForm build(PanelVisualizerState page, Mode mode) {
		return UWForm(page, mode, this, key);
	}
	
	@override	
	String previewString() {
		String output = "";
		for (var s in items) {
			output += s + '\n';
		}
		return output;
	}
	
	@override
	Map toJsonMap() {
		return {
			'id' : id,
			'items' : items,
		};
	}

	@override
	void buildFromJsonMap(Map m) {
		for (var s in m['items']) {
			items.add(s);
		}
	}
}

class UWForm extends UserWidget{
	final UWFormFactory factory;

  UWForm(super.widgetController, super.mode, this.factory, Key key) : super(key: key);

	@override
	State<StatefulWidget> createState() => _UWFormState();
}

class _UWFormState extends State<UWForm> {
	List<TextEditingController> _textControllers = [];

	@override
	void initState() {
		super.initState();

		if (widget.factory.items.length > 0) {
			for (var s in widget.factory.items) {
				_textControllers.add(TextEditingController(text: s));
			}
		} else {
			addRow();
			addRow();
		}
	}

	void addRow() {
		_textControllers.add(TextEditingController());
		widget.factory.items.add("");
	}

	void insertAfter(int index) {
		_textControllers.insert(index, TextEditingController());
		widget.factory.items.insert(index, "");
	}
	
	void removeRow(int index) {
		_textControllers.removeAt(index);
		widget.factory.items.removeAt(index);
	}

	@override
	Widget build(BuildContext context) {
		List<TextField> fields = [];

		for (int i = 0; i < _textControllers.length; i++) {
			var tc = _textControllers[i];
			fields.add(
				TextField(
					decoration: InputDecoration(
						//border: InputBorder.none,
						hintText: 'This is a form!',
					),
					//keyboardType: TextInputType.multiline,
					controller: tc,
					style: TextStyle(fontWeight: FontWeight.bold),
					minLines: 1,
					maxLines: 1024,
					onChanged: (value) {
					  widget.factory.items[i] = value;
						widget.controller.requestSave();
					},
				),
			);
		}

		if (widget.mode == Mode.view) {
			return Container(
				padding: EdgeInsets.only(left: 14, right: 8, top: 4, bottom: 4),
				decoration: BoxDecoration(
					color: COLOR_BACKGROUND_MID,
					//border: Border.all(
					//	width: 0.1,
					//),
					borderRadius: BorderRadius.circular(3),
				),
				child: Column(
					//children: fields,
					children: fields.map((f) {
						return Stack(
							alignment: Alignment.centerRight,
							children: [
								f,
								IconButton(
									icon: Icon(Icons.copy),
									onPressed: () async {
										var controller = f.controller;
										if (controller != null) {
											await Clipboard.setData(ClipboardData(text: controller.text));
										}
									},
								),
							],
						);
					}).toList(),
				),
			);
		}

		List<Widget> editWidgets = [
			Row(
				mainAxisAlignment: MainAxisAlignment.end,
				children: [
					IconButton(
						icon: Icon(Icons.delete),
						onPressed: (){
							widget.controller.remove(widget.key!);
						},
					),
					//IconButton(onPressed: (){}, icon: Icon(Icons.done)),
					IconButton(
						icon: Icon(Icons.add_task),
						onPressed: (){
							widget.controller.insertAfter(widget.key!, UWFormFactory(GlobalKey()));
						},
					),
				],
			),
		];

		for (int i = 0; i < fields.length; i++) {
			editWidgets.add(
				Stack(
					alignment: Alignment.centerRight,
					children: [
						fields[i],
						Row(
							mainAxisAlignment: MainAxisAlignment.end,
							children: [
								IconButton(
									icon: Icon(Icons.add),
									onPressed: (){
										setState(() {
											insertAfter(i+1);
										});
									},
								),
								IconButton(
									icon: Icon(Icons.remove),
									onPressed: (){
										setState(() {
											removeRow(i);
										});
									},
								),
							],
						),
					],
				),
			);
		}
		
		return Container(
			padding: EdgeInsets.only(left: 14, right: 8, top: 2, bottom: 2),
			decoration: BoxDecoration(
				color: COLOR_BACKGROUND_MID,
				border: Border.all(
					width: 1,
				),
				borderRadius: BorderRadius.circular(3),
			),

			child: Column(
			  children: editWidgets,
			),
		);
	}
	
	@override
	void dispose() {
		for (var tc in _textControllers) {
			tc.dispose();
		}
		super.dispose();
	}
}