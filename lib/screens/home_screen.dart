import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/quotes_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/glass_action_button.dart';
import '../widgets/avatar_image.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return AppStrings.goodMorning;
    if (hour < 17) return AppStrings.goodAfternoon;
    return AppStrings.goodEvening;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotesState = ref.watch(quotesProvider);
    final authState = ref.watch(authProvider);
    final themeState = ref.watch(themeProvider);
    final quoteOfTheDay = quotesState.quoteOfTheDay;

    final accentColor = themeState.accentColor;
    final fontScale = themeState.fontScale;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppTheme.textSecondary
        : AppTheme.textSecondaryLight;

    if (quotesState.isLoading && quoteOfTheDay == null) {
      return Center(child: CircularProgressIndicator(color: accentColor));
    }

    if (quoteOfTheDay == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.format_quote_rounded,
              size: 64,
              color: secondaryTextColor,
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.errorLoadingQuotes,
              style: AppTheme.uiTextStyle.copyWith(color: textColor),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => ref.read(quotesProvider.notifier).refresh(),
              child: Text(AppStrings.retry),
            ),
          ],
        ),
      );
    }

    final isFavorite = quotesState.isFavorite(quoteOfTheDay.id);

    return RefreshIndicator(
      onRefresh: () => ref.read(quotesProvider.notifier).refresh(),
      color: accentColor,
      child: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Greeting header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(),
                            style: AppTheme.subheadingStyleThemed(isDark),
                          ),
                          if (authState.profile?.displayName != null)
                            Text(
                              authState.profile!.displayName!,
                              style: AppTheme.bodyStyleThemed(
                                isDark,
                              ).copyWith(fontWeight: FontWeight.w600),
                            ),
                        ],
                      ),
                    ),
                    // Avatar
                    AvatarImage(
                      urlOrData: authState.profile?.avatarUrl,
                      radius: 24,
                      backgroundColor: isDark
                          ? AppTheme.darkCard
                          : AppTheme.lightCard,
                      iconColor: secondaryTextColor,
                    ),
                  ],
                ),

                const SizedBox(height: 60),

                // Quote of the day label
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    AppStrings.quoteOfTheDay,
                    style: AppTheme.labelStyle.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Opening quote mark
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '"',
                    style: AppTheme.quoteTextStyle.copyWith(
                      fontSize: 80 * fontScale,
                      height: 1,
                      color: textColor.withValues(alpha: 0.2),
                    ),
                  ),
                ),

                // Quote text
                Text(
                  quoteOfTheDay.text,
                  style: AppTheme.quoteTextStyle.copyWith(
                    fontSize: 24 * fontScale,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Author
                Text(
                  '— ${quoteOfTheDay.author}',
                  style: AppTheme.authorTextStyleThemed(isDark),
                  textAlign: TextAlign.center,
                ),

                // Extra space for action buttons
                const SizedBox(height: 160),
              ],
            ),
          ),

          // Bottom action buttons - positioned above bottom nav
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Share button
                GlassActionButton(
                  icon: Icons.share_rounded,
                  onPressed: () {
                    Share.share(
                      '"${quoteOfTheDay.text}" — ${quoteOfTheDay.author}',
                    );
                  },
                ),

                // Favorite button
                GlassActionButton(
                  icon: isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  isActive: isFavorite,
                  isLarge: true,
                  onPressed: () {
                    ref
                        .read(quotesProvider.notifier)
                        .toggleFavorite(quoteOfTheDay.id);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
