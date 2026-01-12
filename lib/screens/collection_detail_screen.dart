import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/collections_provider.dart';
import '../providers/quotes_provider.dart';
import '../providers/favorites_provider.dart';
import '../utils/app_theme.dart';
import '../models/collection.dart';
import '../models/quote.dart';
import '../utils/constants.dart';

class CollectionDetailScreen extends ConsumerWidget {
  final QuoteCollection collection;

  const CollectionDetailScreen({super.key, required this.collection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsState = ref.watch(collectionsProvider);
    final quotes = collectionsState.selectedCollectionQuotes;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : AppTheme.textPrimaryLight;

    final colorValue = Color(
      int.parse(collection.color.replaceFirst('#', '0xFF')),
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradientThemed(isDark),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: iconColor),
                      onPressed: () {
                        ref.read(collectionsProvider.notifier).clearSelection();
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 24,
                      decoration: BoxDecoration(
                        color: colorValue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        collection.name,
                        style: AppTheme.headingStyleThemed(
                          isDark,
                        ).copyWith(fontSize: 20),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.more_vert, color: iconColor),
                      onPressed: () {
                        // TODO: Show options menu
                      },
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: collectionsState.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryPurple,
                        ),
                      )
                    : quotes.isEmpty
                    ? _buildEmptyState(isDark)
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: quotes.length,
                        itemBuilder: (context, index) {
                          final quote = quotes[index];
                          return _CollectionQuoteCard(
                            quote: quote,
                            isDark: isDark,
                            onRemove: () {
                              ref
                                  .read(collectionsProvider.notifier)
                                  .removeQuoteFromCollection(
                                    collectionId: collection.id,
                                    quoteId: quote.id,
                                  );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryPurple,
        onPressed: () => _showAddQuoteSheet(context, ref),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddQuoteSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddQuoteSheet(
        collectionId: collection.id,
        onQuoteAdded: () => Navigator.pop(context),
      ),
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
          Icon(Icons.format_quote_rounded, size: 64, color: iconColor),
          const SizedBox(height: 24),
          Text(
            'No quotes yet',
            style: AppTheme.headingStyleThemed(isDark).copyWith(fontSize: 20),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Tap + to add quotes to this collection',
              style: AppTheme.subheadingStyleThemed(isDark),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionQuoteCard extends StatelessWidget {
  final Quote quote;
  final VoidCallback onRemove;
  final bool isDark;

  const _CollectionQuoteCard({
    required this.quote,
    required this.onRemove,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight;
    final iconColor = isDark ? Colors.white54 : AppTheme.textSecondaryLight;

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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        quote.text,
                        style: AppTheme.quoteTextStyleThemed(
                          isDark,
                        ).copyWith(fontSize: 16, height: 1.4, color: textColor),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: iconColor, size: 20),
                      visualDensity: VisualDensity.compact,
                      onPressed: onRemove,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '— ${quote.author}',
                  style: AppTheme.authorTextStyleThemed(
                    isDark,
                  ).copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet widget for adding quotes from the browse list to a collection
class _AddQuoteSheet extends ConsumerWidget {
  final String collectionId;
  final VoidCallback onQuoteAdded;

  const _AddQuoteSheet({
    required this.collectionId,
    required this.onQuoteAdded,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Show all available quotes (Feed + Favorites)
    final quotesState = ref.watch(quotesProvider);
    final favoritesState = ref.watch(favoritesProvider);

    // Merge and deduplicate
    final Map<String, Quote> uniqueQuotes = {};
    for (var q in quotesState.quotes) {
      uniqueQuotes[q.id] = q;
    }
    for (var q in favoritesState.favorites) {
      uniqueQuotes[q.id] = q;
    }
    final allQuotes = uniqueQuotes.values.toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : AppTheme.textPrimaryLight;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Add Quote',
                style: AppTheme.headingStyleThemed(
                  isDark,
                ).copyWith(fontSize: 20),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.close, color: iconColor),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Select a quote to add',
            style: AppTheme.subheadingStyleThemed(isDark),
          ),
          const SizedBox(height: 16),
          if (allQuotes.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'No quotes available. Browse some quotes first!',
                  style: AppTheme.labelStyleThemed(isDark),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: allQuotes.length,
                itemBuilder: (context, index) {
                  final quote = allQuotes[index];
                  return ListTile(
                    title: Text(
                      quote.text,
                      style: AppTheme.bodyStyleThemed(
                        isDark,
                      ).copyWith(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '— ${quote.author}',
                      style: AppTheme.labelStyleThemed(isDark),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: AppTheme.primaryPurple,
                      ),
                      onPressed: () {
                        ref
                            .read(collectionsProvider.notifier)
                            .addQuoteToCollection(
                              collectionId: collectionId,
                              quote: quote,
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(AppStrings.quoteAddedToCollection),
                            backgroundColor: AppTheme.success,
                          ),
                        );
                        onQuoteAdded();
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
