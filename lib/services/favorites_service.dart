import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/quote.dart';

/// Service for managing user favorites with cloud sync
class FavoritesService {
  final SupabaseClient _client = SupabaseConfig.client;

  String? get _userId => _client.auth.currentUser?.id;

  /// Fetch all favorites for current user
  Future<List<Quote>> fetchFavorites() async {
    if (_userId == null) return [];

    final response = await _client
        .from(SupabaseTables.userFavorites)
        .select('quote_id, quotes(*, categories(name))')
        .eq('user_id', _userId!)
        .order('created_at', ascending: false);

    return (response as List)
        .where((item) => item['quotes'] != null)
        .map((item) => Quote.fromJson(item['quotes']))
        .toList();
  }

  /// Check if a quote is favorited
  Future<bool> isFavorite(String quoteId) async {
    if (_userId == null) return false;

    final response = await _client
        .from(SupabaseTables.userFavorites)
        .select('id')
        .eq('user_id', _userId!)
        .eq('quote_id', quoteId)
        .maybeSingle();

    return response != null;
  }

  /// Add quote to favorites
  Future<void> addFavorite(String quoteId) async {
    if (_userId == null) return;

    await _client.from(SupabaseTables.userFavorites).insert({
      'user_id': _userId,
      'quote_id': quoteId,
    });
  }

  /// Remove quote from favorites
  Future<void> removeFavorite(String quoteId) async {
    if (_userId == null) return;

    await _client
        .from(SupabaseTables.userFavorites)
        .delete()
        .eq('user_id', _userId!)
        .eq('quote_id', quoteId);
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(String quoteId) async {
    final isFav = await isFavorite(quoteId);

    if (isFav) {
      await removeFavorite(quoteId);
      return false;
    } else {
      await addFavorite(quoteId);
      return true;
    }
  }

  /// Get favorite quote IDs for quick lookup
  Future<Set<String>> getFavoriteIds() async {
    if (_userId == null) return {};

    final response = await _client
        .from(SupabaseTables.userFavorites)
        .select('quote_id')
        .eq('user_id', _userId!);

    return (response as List).map((item) => item['quote_id'] as String).toSet();
  }

  /// Get favorites count
  Future<int> getFavoritesCount() async {
    if (_userId == null) return 0;

    final response = await _client
        .from(SupabaseTables.userFavorites)
        .select('id')
        .eq('user_id', _userId!);

    return (response as List).length;
  }
}
