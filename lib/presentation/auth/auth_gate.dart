import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/supabase_providers.dart';
import '../family/family_hub_screen.dart';
import 'login_screen.dart';

/// Mengarahkan ke layar login atau hub keluarga berdasarkan status auth.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => const LoginScreen(),
      data: (_) {
        final user = ref.watch(currentUserProvider);
        return user == null ? const LoginScreen() : const FamilyHubScreen();
      },
    );
  }
}
