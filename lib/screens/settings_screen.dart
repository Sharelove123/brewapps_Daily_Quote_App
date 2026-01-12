import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import 'auth/login_screen.dart';
import 'auth/update_password_screen.dart';
import '../services/notification_service.dart';
import 'edit_profile_screen.dart';
import '../widgets/avatar_image.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 8, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      final hour = prefs.getInt('notification_hour') ?? 8;
      final minute = prefs.getInt('notification_minute') ?? 0;
      _notificationTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _saveNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setInt('notification_hour', _notificationTime.hour);
    await prefs.setInt('notification_minute', _notificationTime.minute);

    if (_notificationsEnabled) {
      await NotificationService().requestPermissions();
      await NotificationService().scheduleDailyQuote(_notificationTime);
    } else {
      await NotificationService().cancelDailyQuote();
    }

    final timeStr =
        '${_notificationTime.hour.toString().padLeft(2, '0')}:${_notificationTime.minute.toString().padLeft(2, '0')}:00';
    _updateProfile(notificationTime: timeStr);
  }

  Future<void> _selectNotificationTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryPurple,
              onPrimary: Colors.white,
              surface: AppTheme.darkSurface,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _notificationTime = picked);
      await _saveNotificationSettings();
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final themeState = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            AppStrings.settings,
            style: AppTheme.headingStyleThemed(isDark).copyWith(fontSize: 24),
          ),

          const SizedBox(height: 24),

          // Profile Section (if authenticated)
          if (authState.isAuthenticated) ...[
            _SectionHeader(title: AppStrings.profile, isDark: isDark),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
              },
              child: _buildProfileCard(authState, context, ref, isDark),
            ),
            const SizedBox(height: 24),
          ],

          // Appearance Section
          _SectionHeader(title: AppStrings.appearance, isDark: isDark),
          _buildAppearanceCard(themeState, ref, isDark),

          const SizedBox(height: 24),

          // Notifications Section
          _SectionHeader(title: AppStrings.notifications, isDark: isDark),
          _buildNotificationsCard(isDark),

          const SizedBox(height: 24),

          // Account Section
          _SectionHeader(title: AppStrings.account, isDark: isDark),
          _buildAccountCard(authState, context, ref, isDark),

          const SizedBox(height: 24),

          // Version
          Center(
            child: Text(
              AppStrings.version,
              style: AppTheme.labelStyleThemed(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProfile({
    String? theme,
    String? accentColor,
    double? fontScale,
    String? cardStyle,
    String? notificationTime,
  }) async {
    final authState = ref.read(authProvider);
    if (authState.isAuthenticated && authState.profile != null) {
      final updated = authState.profile!.copyWith(
        theme: theme,
        accentColor: accentColor,
        fontScale: fontScale,
        cardStyle: cardStyle,
        notificationTime: notificationTime,
      );
      await ref.read(authProvider.notifier).updateProfile(updated);
    }
  }

  Widget _buildProfileCard(
    AuthState authState,
    BuildContext context,
    WidgetRef ref,
    bool isDark,
  ) {
    final iconColor = isDark
        ? AppTheme.textSecondary
        : AppTheme.textSecondaryLight;
    return _SettingsCard(
      isDark: isDark,
      child: Row(
        children: [
          AvatarImage(
            urlOrData: authState.profile?.avatarUrl,
            radius: 32,
            backgroundColor: AppTheme.primaryPurple.withValues(alpha: 0.2),
            iconColor: AppTheme.primaryPurple,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authState.profile?.displayName ?? 'User',
                  style: AppTheme.bodyStyleThemed(
                    isDark,
                  ).copyWith(fontWeight: FontWeight.w600, fontSize: 18),
                ),
                Text(
                  authState.profile?.email ?? '',
                  style: AppTheme.labelStyleThemed(isDark),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: iconColor),
        ],
      ),
    );
  }

  Widget _buildAppearanceCard(
    ThemeState themeState,
    WidgetRef ref,
    bool isDark,
  ) {
    final dividerColor = isDark
        ? AppTheme.darkCardBorder
        : AppTheme.lightCardBorder;
    final textColor = isDark ? Colors.white : AppTheme.textPrimaryLight;

    return _SettingsCard(
      isDark: isDark,
      child: Column(
        children: [
          // Theme
          _SettingsRow(
            isDark: isDark,
            title: AppStrings.theme,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ThemeButton(
                  isDark: isDark,
                  label: AppStrings.dark,
                  isSelected: themeState.themeMode == ThemeMode.dark,
                  onTap: () {
                    ref
                        .read(themeProvider.notifier)
                        .setThemeMode(ThemeMode.dark);
                    _updateProfile(theme: 'dark');
                  },
                ),
                _ThemeButton(
                  isDark: isDark,
                  label: AppStrings.light,
                  isSelected: themeState.themeMode == ThemeMode.light,
                  onTap: () {
                    ref
                        .read(themeProvider.notifier)
                        .setThemeMode(ThemeMode.light);
                    _updateProfile(theme: 'light');
                  },
                ),
                _ThemeButton(
                  isDark: isDark,
                  label: AppStrings.system,
                  isSelected: themeState.themeMode == ThemeMode.system,
                  onTap: () {
                    ref
                        .read(themeProvider.notifier)
                        .setThemeMode(ThemeMode.system);
                    _updateProfile(theme: 'system');
                  },
                ),
              ],
            ),
          ),
          Divider(color: dividerColor),

          // Card Style
          _SettingsRow(
            isDark: isDark,
            title: AppStrings.cardStyle,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: QuoteCardStyle.values.map((style) {
                final isSelected = style == themeState.cardStyle;
                // Capitalize first letter
                final label =
                    style.name[0].toUpperCase() + style.name.substring(1);
                return _ThemeButton(
                  isDark: isDark,
                  label: label,
                  isSelected: isSelected,
                  onTap: () {
                    ref.read(themeProvider.notifier).setCardStyle(style);
                    _updateProfile(cardStyle: style.name);
                  },
                );
              }).toList(),
            ),
          ),
          Divider(color: dividerColor),

          // Accent Color
          _SettingsRow(
            isDark: isDark,
            title: AppStrings.accentColor,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: AppTheme.accentColors.entries.map((entry) {
                final isSelected = entry.key == themeState.accentColorName;
                return GestureDetector(
                  onTap: () {
                    ref.read(themeProvider.notifier).setAccentColor(entry.key);
                    _updateProfile(accentColor: entry.key);
                  },
                  child: Container(
                    width: 28,
                    height: 28,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: entry.value,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: isDark ? Colors.white : Colors.black,
                              width: 2,
                            )
                          : null,
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            color: isDark ? Colors.white : Colors.black,
                            size: 16,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
          Divider(color: dividerColor),

          // Font Size
          _SettingsRow(
            isDark: isDark,
            title: AppStrings.fontSize,
            trailing: SizedBox(
              width: 120,
              child: Row(
                children: [
                  Text('A', style: TextStyle(fontSize: 12, color: textColor)),
                  Expanded(
                    child: Slider(
                      value: themeState.fontScale,
                      min: 0.8,
                      max: 1.4,
                      divisions: 6,
                      activeColor: AppTheme.primaryPurple,
                      onChanged: (value) {
                        ref.read(themeProvider.notifier).setFontScale(value);
                        _updateProfile(fontScale: value);
                      },
                    ),
                  ),
                  Text('A', style: TextStyle(fontSize: 18, color: textColor)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsCard(bool isDark) {
    final dividerColor = isDark
        ? AppTheme.darkCardBorder
        : AppTheme.lightCardBorder;
    final secondaryColor = isDark
        ? AppTheme.textSecondary
        : AppTheme.textSecondaryLight;

    return _SettingsCard(
      isDark: isDark,
      child: Column(
        children: [
          _SettingsRow(
            isDark: isDark,
            title: AppStrings.dailyQuoteReminder,
            trailing: Switch(
              value: _notificationsEnabled,
              activeColor: AppTheme.primaryPurple,
              onChanged: (value) async {
                setState(() => _notificationsEnabled = value);
                await _saveNotificationSettings();
              },
            ),
          ),
          Divider(color: dividerColor),
          GestureDetector(
            onTap: _notificationsEnabled ? _selectNotificationTime : null,
            child: _SettingsRow(
              isDark: isDark,
              title: AppStrings.notificationTime,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(_notificationTime),
                    style: AppTheme.labelStyleThemed(isDark).copyWith(
                      color: _notificationsEnabled
                          ? AppTheme.primaryPurple
                          : secondaryColor,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: _notificationsEnabled
                        ? secondaryColor
                        : secondaryColor.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(
    AuthState authState,
    BuildContext context,
    WidgetRef ref,
    bool isDark,
  ) {
    final dividerColor = isDark
        ? AppTheme.darkCardBorder
        : AppTheme.lightCardBorder;
    final iconColor = isDark
        ? AppTheme.textSecondary
        : AppTheme.textSecondaryLight;

    if (!authState.isAuthenticated) {
      return _SettingsCard(
        isDark: isDark,
        child: GestureDetector(
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
          },
          child: _SettingsRow(
            isDark: isDark,
            title: AppStrings.signIn,
            subtitle: AppStrings.signInSubtitle,
            trailing: const Icon(Icons.login, color: AppTheme.primaryPurple),
          ),
        ),
      );
    }

    return _SettingsCard(
      isDark: isDark,
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
            child: _SettingsRow(
              isDark: isDark,
              title: AppStrings.editProfile,
              trailing: Icon(Icons.chevron_right, color: iconColor),
            ),
          ),
          Divider(color: dividerColor),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const UpdatePasswordScreen()),
              );
            },
            child: _SettingsRow(
              isDark: isDark,
              title: AppStrings.changePassword,
              trailing: Icon(Icons.chevron_right, color: iconColor),
            ),
          ),
          Divider(color: dividerColor),
          GestureDetector(
            onTap: () {
              ref.read(authProvider.notifier).signOut();
            },
            child: _SettingsRow(
              isDark: isDark,
              title: AppStrings.signOut,
              trailing: const Icon(Icons.logout, color: AppTheme.error),
              titleColor: AppTheme.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppTheme.labelStyleThemed(
          isDark,
        ).copyWith(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const _SettingsCard({required this.child, this.isDark = true});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = isDark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.glassDecoration(
            borderRadius: 16,
            isDark: isDarkMode,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget trailing;
  final Color? titleColor;
  final bool isDark;

  const _SettingsRow({
    required this.title,
    this.subtitle,
    required this.trailing,
    this.titleColor,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : AppTheme.textPrimaryLight;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodyStyleThemed(
                    isDark,
                  ).copyWith(color: titleColor ?? textColor),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTheme.labelStyleThemed(
                      isDark,
                    ).copyWith(fontSize: 12),
                  ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _ThemeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _ThemeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? AppTheme.primaryPurple
        : (isDark ? AppTheme.darkCard : AppTheme.lightCardBorder);
    final textColor = isSelected
        ? Colors.white
        : (isDark ? Colors.white : AppTheme.textPrimaryLight);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: AppTheme.labelStyleThemed(
            isDark,
          ).copyWith(color: textColor, fontSize: 12),
        ),
      ),
    );
  }
}
