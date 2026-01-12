import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/collection.dart';
import '../models/quote.dart';
import '../services/collections_service.dart';

/// State for collections
class CollectionsState {
  final List<QuoteCollection> collections;
  final QuoteCollection? selectedCollection;
  final List<Quote> selectedCollectionQuotes;
  final bool isLoading;
  final String? error;

  const CollectionsState({
    this.collections = const [],
    this.selectedCollection,
    this.selectedCollectionQuotes = const [],
    this.isLoading = false,
    this.error,
  });

  int get count => collections.length;

  CollectionsState copyWith({
    List<QuoteCollection>? collections,
    QuoteCollection? selectedCollection,
    List<Quote>? selectedCollectionQuotes,
    bool? isLoading,
    String? error,
  }) {
    return CollectionsState(
      collections: collections ?? this.collections,
      selectedCollection: selectedCollection ?? this.selectedCollection,
      selectedCollectionQuotes:
          selectedCollectionQuotes ?? this.selectedCollectionQuotes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Collections state notifier
class CollectionsNotifier extends StateNotifier<CollectionsState> {
  final CollectionsService _service;

  CollectionsNotifier(this._service) : super(const CollectionsState()) {
    loadCollections();
  }

  /// Load all collections
  Future<void> loadCollections() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final collections = await _service.fetchCollections();
      state = state.copyWith(collections: collections, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Create a new collection
  Future<QuoteCollection?> createCollection({
    required String name,
    String? description,
    String color = '#A855F7',
  }) async {
    try {
      final collection = await _service.createCollection(
        name: name,
        description: description,
        color: color,
      );
      state = state.copyWith(collections: [collection, ...state.collections]);
      return collection;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Update a collection
  Future<void> updateCollection(QuoteCollection collection) async {
    try {
      await _service.updateCollection(collection);
      state = state.copyWith(
        collections: state.collections
            .map((c) => c.id == collection.id ? collection : c)
            .toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Delete a collection
  Future<void> deleteCollection(String collectionId) async {
    try {
      await _service.deleteCollection(collectionId);
      state = state.copyWith(
        collections: state.collections
            .where((c) => c.id != collectionId)
            .toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Select a collection and load its quotes
  Future<void> selectCollection(QuoteCollection collection) async {
    state = state.copyWith(
      selectedCollection: collection,
      selectedCollectionQuotes: [],
      isLoading: true,
    );

    try {
      final quotes = await _service.fetchCollectionQuotes(collection.id);
      state = state.copyWith(
        selectedCollectionQuotes: quotes,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Clear selected collection
  void clearSelection() {
    state = state.copyWith(
      selectedCollection: null,
      selectedCollectionQuotes: [],
    );
  }

  /// Add quote to collection
  Future<void> addQuoteToCollection({
    required String collectionId,
    required Quote quote,
  }) async {
    try {
      await _service.addQuoteToCollection(
        collectionId: collectionId,
        quoteId: quote.id,
      );

      // Update quote count
      state = state.copyWith(
        collections: state.collections.map((c) {
          if (c.id == collectionId) {
            return c.copyWith(quoteCount: c.quoteCount + 1);
          }
          return c;
        }).toList(),
      );

      // If this collection is selected, add quote to the list
      if (state.selectedCollection?.id == collectionId) {
        state = state.copyWith(
          selectedCollectionQuotes: [quote, ...state.selectedCollectionQuotes],
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Remove quote from collection
  Future<void> removeQuoteFromCollection({
    required String collectionId,
    required String quoteId,
  }) async {
    try {
      await _service.removeQuoteFromCollection(
        collectionId: collectionId,
        quoteId: quoteId,
      );

      // Update quote count
      state = state.copyWith(
        collections: state.collections.map((c) {
          if (c.id == collectionId) {
            return c.copyWith(quoteCount: c.quoteCount - 1);
          }
          return c;
        }).toList(),
      );

      // If this collection is selected, remove quote from the list
      if (state.selectedCollection?.id == collectionId) {
        state = state.copyWith(
          selectedCollectionQuotes: state.selectedCollectionQuotes
              .where((q) => q.id != quoteId)
              .toList(),
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Refresh collections
  Future<void> refresh() async {
    await loadCollections();
  }
}

/// Provider for collections service
final collectionsServiceProvider = Provider<CollectionsService>((ref) {
  return CollectionsService();
});

/// Provider for collections
final collectionsProvider =
    StateNotifierProvider<CollectionsNotifier, CollectionsState>((ref) {
      final service = ref.watch(collectionsServiceProvider);
      return CollectionsNotifier(service);
    });

/// Provider for collections count
final collectionsCountProvider = Provider<int>((ref) {
  return ref.watch(collectionsProvider).count;
});
