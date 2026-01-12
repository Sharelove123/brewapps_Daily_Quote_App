import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/collection.dart';
import '../models/quote.dart';

/// Service for managing user collections
class CollectionsService {
  final SupabaseClient _client = SupabaseConfig.client;

  String? get _userId => _client.auth.currentUser?.id;

  /// Fetch all collections for current user
  Future<List<QuoteCollection>> fetchCollections() async {
    if (_userId == null) return [];

    final response = await _client
        .from(SupabaseTables.collections)
        .select()
        .eq('user_id', _userId!)
        .order('created_at', ascending: false);

    final collections = <QuoteCollection>[];

    for (final json in response as List) {
      // Get quote count for each collection
      final countResponse = await _client
          .from(SupabaseTables.collectionQuotes)
          .select('id')
          .eq('collection_id', json['id']);

      collections.add(
        QuoteCollection.fromJson({
          ...json,
          'quote_count': (countResponse as List).length,
        }),
      );
    }

    return collections;
  }

  /// Create a new collection
  Future<QuoteCollection> createCollection({
    required String name,
    String? description,
    String color = '#A855F7',
  }) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    final response = await _client
        .from(SupabaseTables.collections)
        .insert({
          'user_id': _userId,
          'name': name,
          'description': description,
          'color': color,
        })
        .select()
        .single();

    return QuoteCollection.fromJson(response);
  }

  /// Update a collection
  Future<void> updateCollection(QuoteCollection collection) async {
    await _client
        .from(SupabaseTables.collections)
        .update({
          'name': collection.name,
          'description': collection.description,
          'color': collection.color,
        })
        .eq('id', collection.id);
  }

  /// Delete a collection
  Future<void> deleteCollection(String collectionId) async {
    // First delete all quotes in the collection
    await _client
        .from(SupabaseTables.collectionQuotes)
        .delete()
        .eq('collection_id', collectionId);

    // Then delete the collection
    await _client
        .from(SupabaseTables.collections)
        .delete()
        .eq('id', collectionId);
  }

  /// Fetch quotes in a collection
  Future<List<Quote>> fetchCollectionQuotes(String collectionId) async {
    final response = await _client
        .from(SupabaseTables.collectionQuotes)
        .select('quote_id, quotes(*, categories(name))')
        .eq('collection_id', collectionId)
        .order('added_at', ascending: false);

    return (response as List)
        .where((item) => item['quotes'] != null)
        .map((item) => Quote.fromJson(item['quotes']))
        .toList();
  }

  /// Add quote to collection
  Future<void> addQuoteToCollection({
    required String collectionId,
    required String quoteId,
  }) async {
    await _client.from(SupabaseTables.collectionQuotes).insert({
      'collection_id': collectionId,
      'quote_id': quoteId,
    });
  }

  /// Remove quote from collection
  Future<void> removeQuoteFromCollection({
    required String collectionId,
    required String quoteId,
  }) async {
    await _client
        .from(SupabaseTables.collectionQuotes)
        .delete()
        .eq('collection_id', collectionId)
        .eq('quote_id', quoteId);
  }

  /// Check if quote is in collection
  Future<bool> isQuoteInCollection({
    required String collectionId,
    required String quoteId,
  }) async {
    final response = await _client
        .from(SupabaseTables.collectionQuotes)
        .select('id')
        .eq('collection_id', collectionId)
        .eq('quote_id', quoteId)
        .maybeSingle();

    return response != null;
  }

  /// Get collections count
  Future<int> getCollectionsCount() async {
    if (_userId == null) return 0;

    final response = await _client
        .from(SupabaseTables.collections)
        .select('id')
        .eq('user_id', _userId!);

    return (response as List).length;
  }
}
