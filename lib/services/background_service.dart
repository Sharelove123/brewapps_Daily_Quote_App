import 'package:workmanager/workmanager.dart';
import '../config/supabase_config.dart';
import 'supabase_quote_service.dart';
import 'widget_service.dart';
import 'notification_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await SupabaseConfig.initialize();

      final service = SupabaseQuoteService();
      final quote = await service.fetchQuoteOfTheDay();

      if (quote != null) {
        // Update widget
        await WidgetService.updateWidget(
          title: quote.text,
          subTitle: quote.author,
        );

        // Show notification with actual quote
        await NotificationService().showNow(
          '✨ Daily Quote',
          '"${quote.text}" — ${quote.author}',
        );
      }
      return Future.value(true);
    } catch (e) {
      print('Background task error: $e');
      return Future.value(false);
    }
  });
}

class BackgroundService {
  static const String _taskName = "updateDailyQuoteWidget";

  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false, // Set true for testing
    );

    // Register periodic task
    await Workmanager().registerPeriodicTask(
      "1", // Unique Name
      _taskName,
      frequency: const Duration(hours: 24),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      initialDelay: const Duration(minutes: 15), // Delay first run a bit
    );
  }
}
