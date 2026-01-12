import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/favorites_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../models/quote.dart';
import 'auth/login_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final favoritesState = ref.watch(favoritesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark
        ? AppTheme.textSecondary
        : AppTheme.textSecondaryLight;

    // Show login prompt if not authenticated
    if (!authState.isAuthenticated) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border_rounded, size: 64, color: iconColor),
              const SizedBox(height: 24),
              Text(
                'Sign in to save favorites',
                style: AppTheme.headingStyleThemed(
                  isDark,
                ).copyWith(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Your favorites will sync across all your devices',
                style: AppTheme.subheadingStyleThemed(isDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: Text(AppStrings.signIn),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Row(
            children: [
              const Icon(Icons.favorite_rounded, color: AppTheme.favorite),
              const SizedBox(width: 12),
              Text(
                AppStrings.myFavorites,
                style: AppTheme.headingStyleThemed(
                  isDark,
                ).copyWith(fontSize: 24),
              ),
              const Spacer(),
              if (favoritesState.favorites.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.darkCard,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${favoritesState.count} ${AppStrings.savedQuotes}',
                    style: AppTheme.labelStyle,
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Content
        Expanded(
          child: favoritesState.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryPurple,
                  ),
                )
              : favoritesState.favorites.isEmpty
              ? _buildEmptyState(isDark)
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.read(favoritesProvider.notifier).refresh(),
                  color: AppTheme.primaryPurple,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: favoritesState.favorites.length,
                    itemBuilder: (context, index) {
                      final quote = favoritesState.favorites[index];
                      return _FavoriteCard(
                        quote: quote,
                        isDark: isDark,
                        onRemove: () {
                          ref
                              .read(favoritesProvider.notifier)
                              .removeFavorite(quote);
                        },
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final iconColor = isDark
        ? Colors.white30
        : AppTheme.textSecondaryLight.withValues(alpha: 0.3);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border_rounded, size: 64, color: iconColor),
          const SizedBox(height: 24),
          Text(
            AppStrings.noFavoritesYet,
            style: AppTheme.headingStyleThemed(isDark).copyWith(fontSize: 20),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              AppStrings.noFavoritesDesc,
              style: AppTheme.subheadingStyleThemed(isDark),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final Quote quote;
  final VoidCallback onRemove;
  final bool isDark;

  const _FavoriteCard({
    required this.quote,
    required this.onRemove,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight;
    final iconColor = isDark ? Colors.white70 : AppTheme.textSecondaryLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.glassDecoration(isDark: isDark),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quote.text,
                  style: AppTheme.quoteTextStyleThemed(
                    isDark,
                  ).copyWith(fontSize: 16, height: 1.4, color: textColor),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '— ${quote.author}',
                        style: AppTheme.authorTextStyleThemed(
                          isDark,
                        ).copyWith(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Share button
                    IconButton(
                      icon: Icon(
                        Icons.share_rounded,
                        color: iconColor,
                        size: 20,
                      ),
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        Share.share('"${quote.text}" — ${quote.author}');
                      },
                    ),
                    // Favorite icon (filled)
                    const Icon(
                      Icons.favorite_rounded,
                      color: AppTheme.favorite,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    // Delete button
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: iconColor,
                        size: 20,
                      ),
                      visualDensity: VisualDensity.compact,
                      onPressed: onRemove,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
