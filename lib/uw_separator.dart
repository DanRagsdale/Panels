import 'package:flutter/material.dart';
import 'package:panels/panel_visualizer.dart';
import 'package:panels/user_widget.dart';

class UWSeparatorFactory extends UWFactory<UWSeparator> {
	static final String id = 'separator';

	UWSeparatorFactory(Key key) : super(key);

	@override
	UWSeparator build(PanelVisualizerState page, Mode mode, bool selected) {
		return UWSeparator(page, mode, selected, key);
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
	final bool selected;

  UWSeparator(super.widgetController, super.mode, this.selected, Key key) : super(key: key);

	@override
	State<UWSeparator> createState() => _UWSeparatorState();
}

class _UWSeparatorState extends State<UWSeparator> {
	@override
	Widget build(BuildContext context) {
		var bar = Container(
			margin: const EdgeInsets.all(8),
			color: Colors.black,
			height: 6.0,
			width: double.infinity,
		);

		if (!widget.selected) {
			return bar;
		}
		
		return Container(
			child: bar,
			color: Colors.green,
		);
	}
}