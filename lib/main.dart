import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/supabase_config.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'services/background_service.dart';
import 'services/supabase_quote_service.dart';
import 'services/widget_service.dart';
import 'services/notification_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/update_password_screen.dart';
import 'screens/main_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Supabase
  await SupabaseConfig.initialize();

  // Initialize Notifications
  await NotificationService().initialize();

  // Initialize Background Service (Widget Updates)
  await BackgroundService.initialize();

  // Initial Widget Update (Fire and forget)
  SupabaseQuoteService().fetchQuoteOfTheDay().then((quote) {
    if (quote != null) {
      WidgetService.updateWidget(title: quote.text, subTitle: quote.author);
    }
  });

  runApp(const ProviderScope(child: QuoteVaultApp()));
}

class QuoteVaultApp extends ConsumerWidget {
  const QuoteVaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final darkTheme = ref.watch(darkThemeProvider);
    final lightTheme = ref.watch(lightThemeProvider);
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'QuoteVault',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: authState.isPasswordRecovery
          ? const UpdatePasswordScreen()
          : authState.isAuthenticated
          ? const MainContainer()
          : const LoginScreen(),
    );
  }
}
