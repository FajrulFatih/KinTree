import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Key messenger global agar SnackBar tetap muncul meski layar berpindah
/// (mis. setelah form di-pop, atau setelah logout berganti ke layar login).
final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Tampilkan SnackBar informasi. [success] mewarnai ikon hijau, jika tidak
/// memakai warna danger.
void showAppSnack(String message, {bool success = true}) {
  final messenger = rootScaffoldMessengerKey.currentState;
  if (messenger == null) return;
  messenger
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_rounded : Icons.error_outline_rounded,
              color: success ? const Color(0xFF8FD3A6) : const Color(0xFFE99B92),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.ink,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
}
