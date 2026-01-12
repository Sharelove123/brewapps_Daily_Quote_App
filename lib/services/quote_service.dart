import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quote.dart';
import '../utils/constants.dart';

class QuoteService {
  Future<Quote> fetchRandomQuote() async {
    try {
      final response = await http.get(Uri.parse(AppConstants.apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return Quote.fromJson(data[0]);
        } else {
          throw Exception('No quotes found');
        }
      } else {
        throw Exception('Failed to load quote');
      }
    } catch (e) {
      // In a real app we might log this.
      // Re-throwing to be handled by provider.
      throw Exception('Failed to connect to service: $e');
    }
  }
}
