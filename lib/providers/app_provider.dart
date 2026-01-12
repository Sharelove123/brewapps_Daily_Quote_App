import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quote.dart';
import '../services/quote_service.dart';
import '../services/storage_service.dart';

/// State class for the quote app
class QuoteState {
  final Quote? currentQuote;
  final List<Quote> favorites;
  final bool isLoading;
  final String? error;

  const QuoteState({
    this.currentQuote,
    this.favorites = const [],
    this.isLoading = false,
    this.error,
  });

  bool get isCurrentQuoteFavorite {
    if (currentQuote == null) return false;
    return favorites.contains(currentQuote);
  }

  QuoteState copyWith({
    Quote? currentQuote,
    List<Quote>? favorites,
    bool? isLoading,
    String? error,
  }) {
    return QuoteState(
      currentQuote: currentQuote ?? this.currentQuote,
      favorites: favorites ?? this.favorites,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// StateNotifier for managing quote state
class QuoteNotifier extends StateNotifier<QuoteState> {
  final QuoteService _quoteService;
  final StorageService _storageService;

  QuoteNotifier(this._quoteService, this._storageService)
    : super(const QuoteState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadFavorites();
    await fetchNewQuote();
  }

  Future<void> _loadFavorites() async {
    final favorites = await _storageService.getFavorites();
    state = state.copyWith(favorites: favorites);
  }

  Future<void> fetchNewQuote() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final quote = await _quoteService.fetchRandomQuote();
      state = state.copyWith(currentQuote: quote, isLoading: false);
    } catch (e) {
      // Fallback quote if we have no current quote
      if (state.currentQuote == null) {
        state = state.copyWith(
          currentQuote: Quote(
            text: "The best way to predict the future is to create it.",
            author: "Abraham Lincoln",
          ),
          isLoading: false,
          error: 'Failed to load quote. Showing offline quote.',
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load quote. Please check your connection.',
        );
      }
    }
  }

  Future<void> toggleFavorite() async {
    if (state.currentQuote == null) return;

    List<Quote> updatedFavorites;
    if (state.isCurrentQuoteFavorite) {
      updatedFavorites = state.favorites
          .where((q) => q != state.currentQuote)
          .toList();
    } else {
      updatedFavorites = [...state.favorites, state.currentQuote!];
    }

    state = state.copyWith(favorites: updatedFavorites);
    await _storageService.saveFavorites(updatedFavorites);
  }

  Future<void> removeFavorite(Quote quote) async {
    final updatedFavorites = state.favorites.where((q) => q != quote).toList();
    state = state.copyWith(favorites: updatedFavorites);
    await _storageService.saveFavorites(updatedFavorites);
  }
}

/// Provider for QuoteService
final quoteServiceProvider = Provider<QuoteService>((ref) => QuoteService());

/// Provider for StorageService
final storageServiceProvider = Provider<StorageService>(
  (ref) => StorageService(),
);

/// Main provider for quote state
final quoteProvider = StateNotifierProvider<QuoteNotifier, QuoteState>((ref) {
  final quoteService = ref.watch(quoteServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return QuoteNotifier(quoteService, storageService);
});
