import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Konfigurasi koneksi Supabase.
///
/// Sumber nilai (berurutan):
///   1. File `.env` (dibaca flutter_dotenv saat startup) — cara utama.
///   2. `--dart-define` saat build/run — fallback / untuk CI.
///
/// Contoh `.env`:
///   SUPABASE_URL=https://xxx.supabase.co
///   SUPABASE_ANON_KEY=eyJhbGci...
class SupabaseConfig {
  static String get url =>
      (dotenv.isInitialized ? dotenv.maybeGet('SUPABASE_URL') : null) ??
      const String.fromEnvironment('SUPABASE_URL');

  static String get anonKey =>
      (dotenv.isInitialized ? dotenv.maybeGet('SUPABASE_ANON_KEY') : null) ??
      const String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Bucket Storage untuk foto profil anggota.
  static const String memberPhotosBucket = 'member-photos';

  static bool get isConfigured {
    final u = url;
    final k = anonKey;
    return u.isNotEmpty &&
        k.isNotEmpty &&
        !u.contains('YOUR_PROJECT_REF') &&
        k != 'YOUR_ANON_KEY';
  }
}
