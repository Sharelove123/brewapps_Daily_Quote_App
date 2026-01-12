import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../utils/app_theme.dart';
import '../services/notification_service.dart';

/// Styles for the quote cards
enum QuoteCardStyle {
  modern, // Glassmorphism (Default)
  classic, // Solid background with shadow
  minimal, // Outline/Border only
}

/// Theme state for the application
class ThemeState {
  final ThemeMode themeMode;
  final String accentColorName;
  final Color accentColor;
  final double fontScale;
  final QuoteCardStyle cardStyle;

  const ThemeState({
    this.themeMode = ThemeMode.system,
    this.accentColorName = 'purple',
    this.accentColor = AppTheme.primaryPurple,
    this.fontScale = 1.0,
    this.cardStyle = QuoteCardStyle.modern,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    String? accentColorName,
    Color? accentColor,
    double? fontScale,
    QuoteCardStyle? cardStyle,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      accentColorName: accentColorName ?? this.accentColorName,
      accentColor: accentColor ?? this.accentColor,
      fontScale: fontScale ?? this.fontScale,
      cardStyle: cardStyle ?? this.cardStyle,
    );
  }
}

/// Theme state notifier for managing app theme
class ThemeNotifier extends StateNotifier<ThemeState> {
  static const String _themeModeKey = 'theme_mode';
  static const String _accentColorKey = 'accent_color';
  static const String _fontScaleKey = 'font_scale';
  static const String _cardStyleKey = 'card_style';

  ThemeNotifier() : super(const ThemeState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Load theme mode
    final themeModeString = prefs.getString(_themeModeKey) ?? 'system';
    final themeMode = _themeModeFromString(themeModeString);

    // Load accent color
    final accentColorName = prefs.getString(_accentColorKey) ?? 'purple';
    final accentColor =
        AppTheme.accentColors[accentColorName] ?? AppTheme.primaryPurple;

    // Load font scale
    final fontScale = prefs.getDouble(_fontScaleKey) ?? 1.0;

    // Load card style
    final cardStyleString = prefs.getString(_cardStyleKey) ?? 'modern';
    final cardStyle = _cardStyleFromString(cardStyleString);

    state = ThemeState(
      themeMode: themeMode,
      accentColorName: accentColorName,
      accentColor: accentColor,
      fontScale: fontScale,
      cardStyle: cardStyle,
    );
  }

  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, _themeModeToString(mode));
    state = state.copyWith(themeMode: mode);
  }

  /// Set accent color
  Future<void> setAccentColor(String colorName) async {
    final color = AppTheme.accentColors[colorName];
    if (color == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accentColorKey, colorName);
    state = state.copyWith(accentColorName: colorName, accentColor: color);
  }

  /// Set font scale
  Future<void> setFontScale(double scale) async {
    final clampedScale = scale.clamp(0.8, 1.4);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontScaleKey, clampedScale);
    state = state.copyWith(fontScale: clampedScale);
  }

  /// Set card style
  Future<void> setCardStyle(QuoteCardStyle style) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cardStyleKey, _cardStyleToString(style));
    state = state.copyWith(cardStyle: style);
  }

  /// Sync settings from user profile
  Future<void> syncFromProfile(UserProfile profile) async {
    final themeMode = _themeModeFromString(profile.theme);
    final accentColorName = profile.accentColor;
    final accentColor =
        AppTheme.accentColors[accentColorName] ?? AppTheme.primaryPurple;
    final fontScale = profile.fontScale;
    final cardStyle = _cardStyleFromString(profile.cardStyle);

    // Save to prefs
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, profile.theme);
    await prefs.setString(_accentColorKey, accentColorName);
    await prefs.setDouble(_fontScaleKey, fontScale);
    await prefs.setString(_cardStyleKey, profile.cardStyle);

    // Sync notification time
    try {
      final parts = profile.notificationTime.split(':');
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]) ?? 8;
        final minute = int.tryParse(parts[1]) ?? 0;
        await prefs.setInt('notification_hour', hour);
        await prefs.setInt('notification_minute', minute);

        // Schedule notification (assuming enabled if time exists)
        // Or check prefs for 'notifications_enabled' first?
        // For sync, we might assume enabled or just update the time used next time enabled.
        // Let's schedule it to be helpful.
        await NotificationService().scheduleDailyQuote(
          TimeOfDay(hour: hour, minute: minute),
        );
      }
    } catch (_) {}

    // Update state
    state = ThemeState(
      themeMode: themeMode,
      accentColorName: accentColorName,
      accentColor: accentColor,
      fontScale: fontScale,
      cardStyle: cardStyle,
    );
  }

  ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.light:
        return 'light';
      default:
        return 'system';
    }
  }

  QuoteCardStyle _cardStyleFromString(String value) {
    switch (value) {
      case 'classic':
        return QuoteCardStyle.classic;
      case 'minimal':
        return QuoteCardStyle.minimal;
      default:
        return QuoteCardStyle.modern;
    }
  }

  String _cardStyleToString(QuoteCardStyle style) {
    switch (style) {
      case QuoteCardStyle.classic:
        return 'classic';
      case QuoteCardStyle.minimal:
        return 'minimal';
      default:
        return 'modern';
    }
  }
}

/// Provider for theme state
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

/// Provider for theme mode
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(themeProvider).themeMode;
});

/// Provider for accent color
final accentColorProvider = Provider<Color>((ref) {
  return ref.watch(themeProvider).accentColor;
});

/// Provider for font scale
final fontScaleProvider = Provider<double>((ref) {
  return ref.watch(themeProvider).fontScale;
});

/// Provider for dark theme data
final darkThemeProvider = Provider<ThemeData>((ref) {
  final accentColor = ref.watch(accentColorProvider);
  return AppTheme.darkTheme(accentColor: accentColor);
});

/// Provider for light theme data
final lightThemeProvider = Provider<ThemeData>((ref) {
  final accentColor = ref.watch(accentColorProvider);
  return AppTheme.lightTheme(accentColor: accentColor);
});
