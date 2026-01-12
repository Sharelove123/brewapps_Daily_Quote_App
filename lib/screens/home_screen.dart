import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/glass_action_button.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quoteState = ref.watch(quoteProvider);

    if (quoteState.isLoading && quoteState.currentQuote == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    final quote = quoteState.currentQuote;
    if (quote == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Unable to load quote.", style: AppTheme.uiTextStyle),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => ref.read(quoteProvider.notifier).fetchNewQuote(),
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // Center content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '“',
                  style: AppTheme.quoteTextStyle.copyWith(
                    fontSize: 80,
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                quote.text,
                style: AppTheme.quoteTextStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Text(
                "— ${quote.author}",
                style: AppTheme.authorTextStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),

        // Bottom Actions
        Positioned(
          left: 0,
          right: 0,
          bottom: 130,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GlassActionButton(
                icon: Icons.share_rounded,
                onPressed: () {
                  Share.share('"${quote.text}" — ${quote.author}');
                },
              ),
              GlassActionButton(
                icon: quoteState.isCurrentQuoteFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                isActive: quoteState.isCurrentQuoteFavorite,
                isLarge: true,
                onPressed: () {
                  ref.read(quoteProvider.notifier).toggleFavorite();
                },
              ),
              GlassActionButton(
                icon: Icons.refresh_rounded,
                onPressed: () {
                  ref.read(quoteProvider.notifier).fetchNewQuote();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
