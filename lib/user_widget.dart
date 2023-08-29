import 'package:flutter/material.dart';
import 'package:panels/panel_visualizer.dart';

import 'editor_page.dart';

/// The backend data structure used to represent a single UserWidget within a NotePanel
/// Stores all persistent information associated with a UserWidget,
/// and can generate the corresponding flutter widget when needed
/// Will be subclassed by each specific UserWidget
abstract class UWFactory<T extends UserWidget> {
	final Key key;
	UWFactory(this.key);

	T build(PanelVisualizerState page, Mode mode);

	/// Receive a WidgetMessage
	/// Return true if the message should continue propagating
	bool receiveMessage(WidgetMessage message) => false;

	String previewString();
}

/// Widget class for user editable widgets
abstract class UserWidget extends StatefulWidget {
	final PanelVisualizerState controller;
	final Mode mode;

	UserWidget(this.controller, this.mode, {required Key key}) : super(key: key);
}

/// Abstract class used for passing messages between UserWidgets
abstract class WidgetMessage {}
