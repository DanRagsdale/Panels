import 'package:flutter/material.dart';

import 'second_page.dart';

abstract class UserWidget {
	Widget build(BuildContext context, Mode mode);
}