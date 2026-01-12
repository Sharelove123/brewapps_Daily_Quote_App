import 'package:home_widget/home_widget.dart';

class WidgetService {
  static const String appGroupId = 'group.brewappsquote';
  static const String androidWidgetName = 'QuoteWidgetProvider';

  static Future<void> updateWidget({
    required String title,
    required String subTitle,
  }) async {
    await HomeWidget.saveWidgetData<String>('quote_title', title);
    await HomeWidget.saveWidgetData<String>('quote_author', subTitle);
    await HomeWidget.updateWidget(
      name: androidWidgetName,
      androidName: androidWidgetName,
    );
  }
}
