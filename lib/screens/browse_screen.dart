import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/quotes_provider.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/quote_card.dart';
import 'search_screen.dart';

class BrowseScreen extends ConsumerStatefulWidget {
  const BrowseScreen({super.key});

  @override
  ConsumerState<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends ConsumerState<BrowseScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(quotesProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final quotesState = ref.watch(quotesProvider);
    final categories = quotesState.categories;
    final quotes = quotesState.quotes;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : AppTheme.textPrimaryLight;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Row(
            children: [
              Text(
                AppStrings.discover,
                style: AppTheme.headingStyleThemed(
                  isDark,
                ).copyWith(fontSize: 24),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.search, color: iconColor),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Category chips
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: categories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                final isSelected = quotesState.selectedCategoryId == null;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _CategoryChip(
                    label: AppStrings.allCategories,
                    isSelected: isSelected,
                    onTap: () {
                      ref.read(quotesProvider.notifier).clearCategoryFilter();
                    },
                  ),
                );
              }

              final category = categories[index - 1];
              final isSelected = quotesState.selectedCategoryId == category.id;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _CategoryChip(
                  label: category.name,
                  icon: category.icon,
                  isSelected: isSelected,
                  onTap: () {
                    ref
                        .read(quotesProvider.notifier)
                        .filterByCategory(category.id);
                  },
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Quotes list
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.read(quotesProvider.notifier).refresh(),
            color: AppTheme.primaryPurple,
            child: quotes.isEmpty && quotesState.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryPurple,
                    ),
                  )
                : quotes.isEmpty
                ? Center(
                    child: Text(
                      'No quotes found',
                      style: AppTheme.emptyStateTextStyle,
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount:
                        quotes.length + (quotesState.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == quotes.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primaryPurple,
                            ),
                          ),
                        );
                      }

                      final quote = quotes[index];
                      final isFavorite = quotesState.isFavorite(quote.id);

                      return QuoteCard(
                        quote: quote,
                        isFavorite: isFavorite,
                        onFavoriteToggle: () {
                          ref
                              .read(quotesProvider.notifier)
                              .toggleFavorite(quote.id);
                        },
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final String? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isSelected
        ? AppTheme.primaryPurple
        : (isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05));

    final borderColor = isSelected
        ? AppTheme.primaryPurple
        : (isDark
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.1));

    final textColor = isSelected
        ? Colors.white
        : (isDark ? Colors.white : AppTheme.textPrimaryLight);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Text(icon!, style: TextStyle(fontSize: 16, color: textColor)),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: AppTheme.labelStyle.copyWith(
                    color: textColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
