import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_profile.dart';

/// Authentication service for Supabase Auth
class AuthService {
  final SupabaseClient _client = SupabaseConfig.client;

  /// Get current user
  User? get currentUser => _client.auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Get auth state stream
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'display_name': displayName},
    );

    // Create profile after signup
    if (response.user != null) {
      await _createProfile(response.user!.id, displayName, email);
    }

    return response;
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'io.supabase.brewappsquote://login-callback',
    );
  }

  /// Update password
  Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  /// Get user profile
  Future<UserProfile?> getProfile() async {
    if (currentUser == null) return null;

    final response = await _client
        .from(SupabaseTables.profiles)
        .select()
        .eq('id', currentUser!.id)
        .maybeSingle();

    if (response == null) return null;

    return UserProfile.fromJson({...response, 'email': currentUser!.email});
  }

  /// Update user profile
  Future<void> updateProfile(UserProfile profile) async {
    await _client.from(SupabaseTables.profiles).upsert(profile.toJson());
  }

  /// Create profile for new user
  Future<void> _createProfile(
    String userId,
    String? displayName,
    String? email,
  ) async {
    try {
      await _client.from(SupabaseTables.profiles).insert({
        'id': userId,
        'display_name': displayName,
        'theme': 'system',
        'accent_color': 'purple',
        'font_scale': 1.0,
        'card_style': 'modern',
        'notification_time': '08:00:00',
      });
    } catch (e) {
      // Log error but allow signup to proceed
      // User can update profile later
      // debugPrint('Error creating profile: $e');
    }
  }

  /// Update avatar
  Future<String?> uploadAvatar(String filePath) async {
    if (currentUser == null) return null;

    final fileName = '${currentUser!.id}/avatar.jpg';

    await _client.storage
        .from('avatars')
        .upload(
          fileName,
          filePath as dynamic,
          fileOptions: const FileOptions(upsert: true),
        );

    final avatarUrl = _client.storage.from('avatars').getPublicUrl(fileName);

    await _client
        .from(SupabaseTables.profiles)
        .update({'avatar_url': avatarUrl})
        .eq('id', currentUser!.id);

    return avatarUrl;
  }
}
