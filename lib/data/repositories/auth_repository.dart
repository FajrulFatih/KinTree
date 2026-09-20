import 'package:supabase_flutter/supabase_flutter.dart';

/// Abstraksi Supabase Auth (Email/Password + Google OAuth).
class AuthRepository {
  final SupabaseClient _client;
  AuthRepository(this._client);

  Session? get currentSession => _client.auth.currentSession;
  User? get currentUser => _client.auth.currentUser;

  /// Stream perubahan status auth (dipakai auth gate).
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) =>
      _client.auth.signInWithPassword(email: email, password: password);

  Future<void> signUp({
    required String email,
    required String password,
  }) =>
      _client.auth.signUp(email: email, password: password);

  /// Google OAuth via browser eksternal (tidak perlu konfigurasi native).
  Future<void> signInWithGoogle() =>
      _client.auth.signInWithOAuth(OAuthProvider.google);

  Future<void> signOut() => _client.auth.signOut();
}
