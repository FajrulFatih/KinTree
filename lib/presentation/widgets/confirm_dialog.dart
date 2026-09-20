import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Dialog konfirmasi bergaya v2: badge ikon bulat, judul serif di tengah,
/// body (boleh rich), lalu dua tombol (Batal + aksi berwarna).
Future<bool> showConfirmDialog(
  BuildContext context, {
  required IconData icon,
  required Color accent,
  required String title,
  required Widget content,
  required String confirmLabel,
  IconData? confirmIcon,
  Color? confirmColor,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: AppColors.page,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accent, size: 26),
            ),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style: AppTheme.serif(size: 20, weight: FontWeight.w600)),
            const SizedBox(height: 10),
            DefaultTextStyle(
              style: AppTheme.sans(
                  size: 14, color: AppColors.inkSoft, height: 1.45),
              textAlign: TextAlign.center,
              child: content,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: confirmColor ?? AppColors.brand,
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    icon: confirmIcon == null
                        ? const SizedBox.shrink()
                        : Icon(confirmIcon, size: 18),
                    label: Text(confirmLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}

/// Helper membuat span teks tebal berwarna untuk body dialog.
TextSpan emphasis(String text, {Color color = AppColors.ink}) => TextSpan(
      text: text,
      style: AppTheme.sans(
          size: 14, weight: FontWeight.w700, color: color, height: 1.45),
    );

TextSpan plain(String text) => TextSpan(
      text: text,
      style:
          AppTheme.sans(size: 14, color: AppColors.inkSoft, height: 1.45),
    );
