// 9.6 — Widget test layar utama (LoginScreen) memastikan UI ter-render
// tanpa Supabase (provider hanya diakses saat aksi tombol).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kintree/presentation/auth/login_screen.dart';

void main() {
  testWidgets('LoginScreen menampilkan field & tombol penting', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: LoginScreen()),
      ),
    );

    // Judul aplikasi.
    expect(find.text('KinTree'), findsOneWidget);
    // Dua input: email & kata sandi.
    expect(find.byType(TextFormField), findsNWidgets(2));
    // Aksi-aksi.
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.text('Belum punya akun? Daftar'), findsOneWidget);
  });

  testWidgets('Validasi: email/sandi kosong memunculkan pesan error',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.tap(find.text('Masuk'));
    await tester.pump();

    expect(find.text('Email tidak valid'), findsOneWidget);
    expect(find.text('Minimal 6 karakter'), findsOneWidget);
  });
}
