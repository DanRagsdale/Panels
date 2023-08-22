import 'package:flutter/material.dart';
import 'package:panels/panel_visualizer.dart';

import 'editor_page.dart';

// Class for user editable widgets
abstract class UserWidget extends StatefulWidget {
	final PanelVisualizerState controller;
	final Mode mode;

	UserWidget(this.controller, this.mode, {required Key key}) : super(key: key);
}
