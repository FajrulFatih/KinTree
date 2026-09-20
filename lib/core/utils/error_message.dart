import 'package:supabase_flutter/supabase_flutter.dart';

/// Mengubah exception mentah menjadi pesan yang ramah pengguna (Bahasa
/// Indonesia). Menangani kasus luring secara khusus karena penulisan ke
/// Supabase membutuhkan koneksi.
String friendlyError(Object e) {
  if (e is AuthException) return e.message;

  if (e is PostgrestException) {
    if (e.message.contains('row-level security')) {
      return 'Anda tidak memiliki akses ke data ini.';
    }
    return e.message;
  }

  if (e is StorageException) return e.message;

  final s = e.toString();
  if (s.contains('SocketException') ||
      s.contains('Failed host lookup') ||
      s.contains('ClientException') ||
      s.contains('Connection')) {
    return 'Sepertinya Anda sedang luring. Periksa koneksi lalu coba lagi.';
  }

  return 'Terjadi kesalahan. Silakan coba lagi.';
}
