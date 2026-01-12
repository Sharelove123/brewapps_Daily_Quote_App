import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/quotes_provider.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../models/quote.dart';
import '../widgets/quote_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _searchType = 'all'; // 'all', 'text', 'author'
  List<Quote> _results = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    // Use the quotes provider to search
    await ref.read(quotesProvider.notifier).search(query);

    final quotesState = ref.read(quotesProvider);
    setState(() {
      _results = quotesState.searchResults;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final quotesState = ref.watch(quotesProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Search Quotes',
                        style: AppTheme.headingStyle.copyWith(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),

              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: AppTheme.glassDecoration(borderRadius: 16),
                      child: TextField(
                        controller: _searchController,
                        style: AppTheme.bodyStyle,
                        decoration: InputDecoration(
                          hintText: AppStrings.searchQuotes,
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppTheme.textSecondary,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: AppTheme.textSecondary,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    _search('');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        onChanged: _search,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Filter chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'All',
                      isSelected: _searchType == 'all',
                      onTap: () => setState(() => _searchType = 'all'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Quote Text',
                      isSelected: _searchType == 'text',
                      onTap: () => setState(() => _searchType = 'text'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Author',
                      isSelected: _searchType == 'author',
                      onTap: () => setState(() => _searchType = 'author'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Results
              Expanded(
                child: _isSearching
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryPurple,
                        ),
                      )
                    : _searchController.text.isEmpty
                    ? _buildEmptyState()
                    : _results.isEmpty
                    ? _buildNoResults()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final quote = _results[index];
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search, size: 64, color: Colors.white30),
          const SizedBox(height: 24),
          Text(
            'Search for quotes',
            style: AppTheme.headingStyle.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Find quotes by keyword or author name',
              style: AppTheme.emptyStateTextStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.white30),
          const SizedBox(height: 24),
          Text(
            'No quotes found',
            style: AppTheme.headingStyle.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Try a different search term',
              style: AppTheme.emptyStateTextStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryPurple
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryPurple
                : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: AppTheme.labelStyle.copyWith(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
