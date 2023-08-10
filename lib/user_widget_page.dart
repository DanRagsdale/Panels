import 'package:panels/user_widget.dart';

class PanelPage {
	List<UserWidgetFactory> widgetFactories;

	PanelPage(this.widgetFactories);

	List<UserWidget> BuildWidgetList(PanelControllerState widgetController) {
		List<UserWidget> outputList = [];

		for (var w in widgetFactories) {
			outputList.add(w.build(widgetController));
		}

		return outputList;
	}

	String getPreview() {
		return "Preview!";
	}

	String getTitle() {
		return "Title!";
	}
}