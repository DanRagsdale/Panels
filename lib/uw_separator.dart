import 'package:flutter/material.dart';
import 'package:panels/panel_visualizer.dart';
import 'package:panels/user_widget.dart';

import 'editor_page.dart';

class UWSeparatorFactory extends UWFactory<UWSeparator> {
	static final String id = 'separator';

	UWSeparatorFactory(Key key) : super(key);

	@override
	UWSeparator build(PanelVisualizerState page, Mode mode) {
		return UWSeparator(page, mode, key);
	}
	
	@override	
	String previewString() => "⸺⸺⸺⸺⸺⸺⸺";
	
	@override
	Map toJsonMap() {
		return {
			'id' : id,
		};
	}

	@override
	void buildFromJsonMap(Map m) {}
}

class UWSeparator extends UserWidget{
  UWSeparator(super.widgetController, super.mode, Key key) : super(key: key);

	@override
	State<UWSeparator> createState() => _UWSeparatorState();
}

class _UWSeparatorState extends State<UWSeparator> {
	@override
	Widget build(BuildContext context) {
		List<Widget> items = [
			Expanded(
				child: Container(
					margin: const EdgeInsets.all(8),
					color: Colors.black,
					height: 6.0,
				),
			),
		];
		if (widget.mode == Mode.edit) {
			items.add(
				IconButton(
					icon: Icon(Icons.delete),
					onPressed: () {
						setState(() => widget.controller.remove(widget.key!));
					},
				),
			);
		}

		return Row(
			children: items,
		);
	}
}