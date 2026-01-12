import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase configuration and initialization
class SupabaseConfig {
  static late final SupabaseClient _client;

  /// Initialize Supabase with environment variables
  static Future<void> initialize() async {
    // Load environment variables
    await dotenv.load(fileName: '.env');

    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception(
        'Missing Supabase configuration. '
        'Please ensure SUPABASE_URL and SUPABASE_ANON_KEY are set in .env file.',
      );
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
    );

    _client = Supabase.instance.client;
  }

  /// Get Supabase client instance
  static SupabaseClient get client => _client;

  /// Get current authenticated user
  static User? get currentUser => _client.auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Get auth state stream
  static Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;
}

/// Table names for Supabase database
class SupabaseTables {
  static const String quotes = 'quotes';
  static const String categories = 'categories';
  static const String profiles = 'profiles';
  static const String userFavorites = 'user_favorites';
  static const String collections = 'collections';
  static const String collectionQuotes = 'collection_quotes';
  static const String dailyQuotes = 'daily_quotes';
}
