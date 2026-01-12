import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quote.dart';
import '../services/favorites_service.dart';

/// State for favorites
class FavoritesState {
  final List<Quote> favorites;
  final bool isLoading;
  final String? error;

  const FavoritesState({
    this.favorites = const [],
    this.isLoading = false,
    this.error,
  });

  int get count => favorites.length;

  FavoritesState copyWith({
    List<Quote>? favorites,
    bool? isLoading,
    String? error,
  }) {
    return FavoritesState(
      favorites: favorites ?? this.favorites,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Favorites state notifier
class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final FavoritesService _service;

  FavoritesNotifier(this._service) : super(const FavoritesState()) {
    loadFavorites();
  }

  /// Load all favorites
  Future<void> loadFavorites() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final favorites = await _service.fetchFavorites();
      state = state.copyWith(favorites: favorites, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Remove a favorite
  Future<void> removeFavorite(Quote quote) async {
    try {
      await _service.removeFavorite(quote.id);
      state = state.copyWith(
        favorites: state.favorites.where((q) => q.id != quote.id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Refresh favorites without showing full loading state
  Future<void> refresh() async {
    try {
      final favorites = await _service.fetchFavorites();
      state = state.copyWith(favorites: favorites, error: null);
    } catch (e) {
      // Keep existing favorites on error, just update error state
      state = state.copyWith(error: e.toString());
    }
  }

  /// Check if quote is favorite
  bool isFavorite(String quoteId) {
    return state.favorites.any((q) => q.id == quoteId);
  }
}

/// Provider for favorites
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
      final service = FavoritesService();
      return FavoritesNotifier(service);
    });

/// Provider for favorites count
final favoritesCountProvider = Provider<int>((ref) {
  return ref.watch(favoritesProvider).count;
});
