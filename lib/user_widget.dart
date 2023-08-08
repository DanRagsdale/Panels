import 'package:flutter/material.dart';

import 'second_page.dart';
import 'uw_separator.dart';
import 'uw_check.dart';
import 'uw_text.dart';

// Class for user editable widgets
// Within flutter, this functions as a widget builder, not a proper flutter widget
abstract class UserWidget {
	final UWControllerState widgetController;
	
	UserWidget(this.widgetController);

	Widget build(BuildContext context, Mode mode);
}

class UWController extends StatefulWidget {
	final Mode mode;
	UWController(this.mode);

	@override
	State<StatefulWidget> createState() => UWControllerState();
}

// Backend for the procedural list of user widgets
class UWControllerState extends State<UWController> {
	List<UserWidget> widgets = [];

	UWControllerState(){
		widgets.add(UWSeparator(this));
		widgets.add(UWCheck(this));
		widgets.add(UWText(this));
	}

	void add(UserWidget w) {
		setState(() {
			widgets.add(w);
		});
	}

	// Inserts widget w into the list immediatly after widget i
	void insertAfter(UserWidget i, UserWidget w) {
		int index = widgets.indexOf(i);
		if (index >= 0) {
			setState(() {
				widgets.insert(index + 1, w);
			});
		}
	}
	
	void remove(UserWidget w){
		setState(() {
			widgets.remove(w);
		});
	}

	@override
	Widget build(BuildContext context) {
		UWListBuilder testBuilder = UWListBuilder(widget.mode, this);

		return ListView.custom(
			padding: const EdgeInsets.all(6),
			childrenDelegate: testBuilder,
		);
	}
}

// Class that handles populating the Listview with user widgets from the widget controller.
class UWListBuilder extends SliverChildDelegate{
	final Mode mode;
	final UWControllerState widgetController;
	
	UWListBuilder(this.mode, this.widgetController);

	@override
	Widget? build(BuildContext context, int index) {
		if (index < widgetController.widgets.length){
			return widgetController.widgets[index].build(context, mode);
		}
		return null;
	}

	@override
	bool shouldRebuild(covariant UWListBuilder oldDelegate) {
		//TODO optimize UserWidget shouldRebuild
		return true;
	}
}
