import 'package:flutter/material.dart';
import 'package:panels/panel_visualizer.dart';
import 'package:panels/user_widget.dart';

import 'main.dart';
import 'editor_page.dart';

class MessageUncheck extends WidgetMessage {}

enum ControlMode {
	all("Control all"),
	connected("Control Connected");
	
	const ControlMode(this.text);

	final String text;
}

class UWCheckControllerFactory extends UWFactory<UWCheckController> {
	UWCheckControllerFactory(Key key) : super(key);

	ControlMode controlMode = ControlMode.all;

	@override
	UWCheckController build(PanelVisualizerState page, Mode mode) {
		return UWCheckController(page, mode, this, key);
	}

	@override	
	String previewString() {
		return "Check Controller";
	}

	@override
	Map toJsonMap() {
		return {
			'id' : 'check_controller',
			'all' : controlMode == ControlMode.all,
		};
	}

	@override
	void buildFromJsonMap(Map m) {
		controlMode = m['all'] ? ControlMode.all : ControlMode.connected;
	}
}

class UWCheckController extends UserWidget {
	final UWCheckControllerFactory factory;

	UWCheckController(super.widgetController, super.mode, this.factory, Key key) : super(key: key);

	@override
	State<StatefulWidget> createState() => _UWCheckControllerState();
}

class _UWCheckControllerState extends State<UWCheckController> {
	@override
	Widget build(BuildContext context) {
		var button = ElevatedButton(
			style: ButtonStyle(
				backgroundColor: MaterialStateColor.resolveWith((states) => COLOR_MENU_COLD),
			),
 			child: Text("Uncheck Completed"),
			onPressed: () {
				if (widget.factory.controlMode == ControlMode.all) {
					widget.controller.broadcastMessage(MessageUncheck());
				} else if (widget.factory.controlMode == ControlMode.connected){
					widget.controller.propagateMessage(widget.factory, MessageUncheck());
				}
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
				child: Row(children: [button]),
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
				mainAxisAlignment: MainAxisAlignment.start,
				children: [
					button,
					SizedBox(
						width: 15,
					),
					DropdownButton<ControlMode>(
						value: widget.factory.controlMode,
						onChanged: (ControlMode? value) {
							setState(() {
								widget.factory.controlMode = value!;
							});
						},
						items: ControlMode.values.map((e) {
							return DropdownMenuItem<ControlMode>(
								value: e,
								child: Text(e.text),
							);
						}).toList(),
					),
					Spacer(),

					IconButton(
						icon: Icon(Icons.delete),
						onPressed: () {
							widget.controller.remove(widget.key!);
						},
					),
					//IconButton(
					//	icon: Icon(Icons.add_task),
					//	onPressed: (){
					//		widget.controller.insertAfter(widget.key!, UWCheckControllerFactory(GlobalKey()));
					//	},
					//),
				],
			),
		);
	}
}