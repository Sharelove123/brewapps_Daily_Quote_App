import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../models/quote.dart';
import '../utils/app_theme.dart';
import '../screens/quote_card_generator.dart';
import '../providers/theme_provider.dart';

/// Reusable quote card widget for browse and other screens
class QuoteCard extends ConsumerWidget {
  final Quote quote;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onTap;

  const QuoteCard({
    super.key,
    required this.quote,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white70 : Colors.black54;
    final cardStyle = themeState.cardStyle;

    BoxDecoration decoration;
    TextStyle quoteStyle;
    TextStyle authorStyle;

    // Define styles based on QuoteCardStyle
    switch (cardStyle) {
      case QuoteCardStyle.classic:
        // Classic: Solid background, shadow, rounded corners
        decoration = BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        );
        quoteStyle = AppTheme.quoteTextStyleThemed(isDark);
        authorStyle = AppTheme.authorTextStyleThemed(isDark);
        break;

      case QuoteCardStyle.minimal:
        // Minimal: Transparent, Border only, sharper corners
        decoration = BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: themeState.accentColor.withValues(alpha: 0.5),
            width: 1.5,
          ),
        );
        quoteStyle = AppTheme.quoteTextStyleThemed(isDark);
        authorStyle = AppTheme.authorTextStyleThemed(isDark);
        break;

      case QuoteCardStyle.modern:
        // Modern: Glassmorphism (Default)
        decoration = AppTheme.glassDecoration(isDark: isDark);
        quoteStyle = AppTheme.quoteTextStyleThemed(isDark);
        authorStyle = AppTheme.authorTextStyleThemed(isDark);
        break;
    }

    Widget content = Container(
      padding: const EdgeInsets.all(20),
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"${quote.text}"',
            style: quoteStyle.copyWith(fontSize: 16, height: 1.4),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  '— ${quote.author}',
                  style: authorStyle.copyWith(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onFavoriteToggle != null) ...[
                IconButton(
                  icon: Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFavorite ? AppTheme.favorite : iconColor,
                    size: 22,
                  ),
                  visualDensity: VisualDensity.compact,
                  onPressed: onFavoriteToggle,
                ),
              ],
              // Create card button
              IconButton(
                icon: Icon(Icons.image_rounded, color: iconColor, size: 20),
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => QuoteCardGenerator(quote: quote),
                    ),
                  );
                },
              ),
              // Share text button
              IconButton(
                icon: Icon(Icons.share_rounded, color: iconColor, size: 20),
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  Share.share('"${quote.text}" — ${quote.author}');
                },
              ),
            ],
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: cardStyle == QuoteCardStyle.modern
            ? ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: content,
                ),
              )
            : content,
      ),
    );
  }
}
