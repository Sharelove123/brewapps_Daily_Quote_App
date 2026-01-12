import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/quote.dart';
import '../models/category.dart';

/// Service for fetching and managing quotes from Supabase
class SupabaseQuoteService {
  final SupabaseClient _client = SupabaseConfig.client;

  /// Fetch quotes with pagination
  Future<List<Quote>> fetchQuotes({
    int page = 0,
    int limit = 20,
    String? categoryId,
    String? searchQuery,
    String? author,
  }) async {
    var query = _client
        .from(SupabaseTables.quotes)
        .select('*, categories(name)');

    // Filter by category
    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }

    // Search by text or author
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or('text.ilike.%$searchQuery%,author.ilike.%$searchQuery%');
    }

    // Filter by author
    if (author != null && author.isNotEmpty) {
      query = query.ilike('author', '%$author%');
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(page * limit, (page + 1) * limit - 1);

    return (response as List).map((json) => Quote.fromJson(json)).toList();
  }

  /// Fetch a single quote by ID
  Future<Quote?> fetchQuoteById(String id) async {
    final response = await _client
        .from(SupabaseTables.quotes)
        .select('*, categories(name)')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Quote.fromJson(response);
  }

  /// Fetch quote of the day
  Future<Quote?> fetchQuoteOfTheDay() async {
    final today = DateTime.now().toIso8601String().split('T')[0];

    // First try to get today's quote from daily_quotes table
    final dailyQuote = await _client
        .from(SupabaseTables.dailyQuotes)
        .select('quote_id, quotes(*, categories(name))')
        .eq('date', today)
        .maybeSingle();

    if (dailyQuote != null && dailyQuote['quotes'] != null) {
      return Quote.fromJson(dailyQuote['quotes']);
    }

    // If no daily quote set, get a random featured quote
    final featuredQuotes = await _client
        .from(SupabaseTables.quotes)
        .select('*, categories(name)')
        .eq('is_featured', true)
        .limit(10);

    if ((featuredQuotes as List).isNotEmpty) {
      // Pick a random featured quote
      final randomIndex = DateTime.now().day % featuredQuotes.length;
      return Quote.fromJson(featuredQuotes[randomIndex]);
    }

    // Fallback: get any random quote
    final randomQuotes = await _client
        .from(SupabaseTables.quotes)
        .select('*, categories(name)')
        .limit(1);

    if ((randomQuotes as List).isNotEmpty) {
      return Quote.fromJson(randomQuotes[0]);
    }

    return null;
  }

  /// Fetch all categories
  Future<List<Category>> fetchCategories() async {
    final response = await _client
        .from(SupabaseTables.categories)
        .select()
        .order('name');

    return (response as List).map((json) => Category.fromJson(json)).toList();
  }

  /// Get quotes count by category
  Future<Map<String, int>> getCategoryQuoteCounts() async {
    final response = await _client
        .from(SupabaseTables.quotes)
        .select('category_id');

    final counts = <String, int>{};
    for (final quote in response as List) {
      final categoryId = quote['category_id'] as String?;
      if (categoryId != null) {
        counts[categoryId] = (counts[categoryId] ?? 0) + 1;
      }
    }
    return counts;
  }

  /// Search quotes
  Future<List<Quote>> searchQuotes(String query) async {
    if (query.isEmpty) return [];

    final response = await _client
        .from(SupabaseTables.quotes)
        .select('*, categories(name)')
        .or('text.ilike.%$query%,author.ilike.%$query%')
        .limit(50);

    return (response as List).map((json) => Quote.fromJson(json)).toList();
  }
}
