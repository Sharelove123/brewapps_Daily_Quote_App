import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quote.dart';
import '../models/category.dart';
import '../services/supabase_quote_service.dart';
import '../services/favorites_service.dart';

/// State for quotes
class QuotesState {
  final Quote? quoteOfTheDay;
  final List<Quote> quotes;
  final List<Quote> searchResults;
  final List<Category> categories;
  final Set<String> favoriteIds;
  final String? selectedCategoryId;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String? error;
  final String searchQuery;

  const QuotesState({
    this.quoteOfTheDay,
    this.quotes = const [],
    this.searchResults = const [],
    this.categories = const [],
    this.favoriteIds = const {},
    this.selectedCategoryId,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 0,
    this.error,
    this.searchQuery = '',
  });

  bool isFavorite(String quoteId) => favoriteIds.contains(quoteId);

  QuotesState copyWith({
    Quote? quoteOfTheDay,
    List<Quote>? quotes,
    List<Quote>? searchResults,
    List<Category>? categories,
    Set<String>? favoriteIds,
    String? selectedCategoryId,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    String? error,
    String? searchQuery,
  }) {
    return QuotesState(
      quoteOfTheDay: quoteOfTheDay ?? this.quoteOfTheDay,
      quotes: quotes ?? this.quotes,
      searchResults: searchResults ?? this.searchResults,
      categories: categories ?? this.categories,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Quotes state notifier
class QuotesNotifier extends StateNotifier<QuotesState> {
  final SupabaseQuoteService _quoteService;
  final FavoritesService _favoritesService;

  QuotesNotifier(this._quoteService, this._favoritesService)
    : super(const QuotesState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      await Future.wait([
        _loadQuoteOfTheDay(),
        _loadCategories(),
        _loadFavoriteIds(),
        _loadQuotes(),
      ]);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> _loadQuoteOfTheDay() async {
    final quote = await _quoteService.fetchQuoteOfTheDay();
    state = state.copyWith(quoteOfTheDay: quote);
  }

  Future<void> _loadCategories() async {
    final categories = await _quoteService.fetchCategories();
    state = state.copyWith(categories: categories);
  }

  Future<void> _loadFavoriteIds() async {
    final ids = await _favoritesService.getFavoriteIds();
    state = state.copyWith(favoriteIds: ids);
  }

  Future<void> _loadQuotes({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        currentPage: 0,
        quotes: [],
        hasMore: true,
        isLoading: true,
      );
    }

    final quotes = await _quoteService.fetchQuotes(
      page: state.currentPage,
      categoryId: state.selectedCategoryId,
    );

    state = state.copyWith(
      quotes: refresh ? quotes : [...state.quotes, ...quotes],
      hasMore: quotes.length >= 20,
      isLoading: false,
      isLoadingMore: false,
    );
  }

  /// Refresh all data
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    await _initialize();
  }

  /// Load more quotes (pagination)
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(
      isLoadingMore: true,
      currentPage: state.currentPage + 1,
    );

    await _loadQuotes();
  }

  /// Filter by category
  Future<void> filterByCategory(String? categoryId) async {
    if (categoryId == state.selectedCategoryId) return;

    state = state.copyWith(
      selectedCategoryId: categoryId,
      quotes: [],
      currentPage: 0,
      hasMore: true,
      isLoading: true,
    );

    await _loadQuotes();
  }

  /// Clear category filter
  Future<void> clearCategoryFilter() async {
    await filterByCategory(null);
  }

  /// Search quotes
  Future<void> search(String query) async {
    state = state.copyWith(searchQuery: query, isLoading: true);

    if (query.isEmpty) {
      state = state.copyWith(searchResults: [], isLoading: false);
      return;
    }

    try {
      final results = await _quoteService.searchQuotes(query);
      state = state.copyWith(searchResults: results, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Toggle favorite for a quote
  Future<void> toggleFavorite(String quoteId) async {
    final newFavoriteIds = Set<String>.from(state.favoriteIds);

    if (newFavoriteIds.contains(quoteId)) {
      newFavoriteIds.remove(quoteId);
      await _favoritesService.removeFavorite(quoteId);
    } else {
      newFavoriteIds.add(quoteId);
      await _favoritesService.addFavorite(quoteId);
    }

    state = state.copyWith(favoriteIds: newFavoriteIds);
  }

  /// Refresh quote of the day
  Future<void> refreshQuoteOfTheDay() async {
    await _loadQuoteOfTheDay();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for quote service
final quoteServiceProvider = Provider<SupabaseQuoteService>((ref) {
  return SupabaseQuoteService();
});

/// Provider for favorites service
final favoritesServiceProvider = Provider<FavoritesService>((ref) {
  return FavoritesService();
});

/// Provider for quotes state
final quotesProvider = StateNotifierProvider<QuotesNotifier, QuotesState>((
  ref,
) {
  final quoteService = ref.watch(quoteServiceProvider);
  final favoritesService = ref.watch(favoritesServiceProvider);
  return QuotesNotifier(quoteService, favoritesService);
});

/// Provider for quote of the day
final quoteOfTheDayProvider = Provider<Quote?>((ref) {
  return ref.watch(quotesProvider).quoteOfTheDay;
});

/// Provider for categories
final categoriesProvider = Provider<List<Category>>((ref) {
  return ref.watch(quotesProvider).categories;
});
