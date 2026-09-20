import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_snackbar.dart';
import 'presentation/auth/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Format tanggal Bahasa Indonesia (dipakai DateFormat('…','id')).
  await initializeDateFormatting('id', null);

  // Muat .env bila ada. Opsional — kredensial juga bisa via --dart-define.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env tidak ditemukan; lanjut pakai --dart-define jika tersedia.
  }

  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      // anon key (format JWT) tetap didukung pada free tier.
      // ignore: deprecated_member_use
      anonKey: SupabaseConfig.anonKey,
    );
  }

  runApp(const ProviderScope(child: KinTreeApp()));
}

class KinTreeApp extends StatelessWidget {
  const KinTreeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KinTree',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      theme: AppTheme.light(),
      home: SupabaseConfig.isConfigured
          ? const AuthGate()
          : const _ConfigMissingScreen(),
    );
  }
}

/// Ditampilkan jika SUPABASE_URL / SUPABASE_ANON_KEY belum disuplai via
/// --dart-define. Mencegah crash dan memberi instruksi yang jelas.
class _ConfigMissingScreen extends StatelessWidget {
  const _ConfigMissingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 56),
              const SizedBox(height: 16),
              Text('Konfigurasi Supabase belum diisi',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              const Text(
                'Jalankan aplikasi dengan menyertakan kredensial:\n\n'
                'flutter run \\\n'
                '  --dart-define=SUPABASE_URL=https://xxx.supabase.co \\\n'
                '  --dart-define=SUPABASE_ANON_KEY=eyJhbGci...',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
