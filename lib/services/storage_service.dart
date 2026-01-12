import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quote.dart';

class StorageService {
  static const String _favoritesKey = 'favorite_quotes';

  Future<List<Quote>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesJson = prefs.getString(_favoritesKey);
    if (favoritesJson == null) return [];

    try {
      final List<dynamic> decode = jsonDecode(favoritesJson);
      return decode.map((e) => Quote.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveFavorites(List<Quote> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      favorites.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(_favoritesKey, encoded);
  }
}
