import 'package:flutter/material.dart';

import 'second_page.dart';

abstract class UserWidget {
	final UWDisplayState widgetController;
	
	UserWidget(this.widgetController);

	Widget build(BuildContext context, Mode mode);
}