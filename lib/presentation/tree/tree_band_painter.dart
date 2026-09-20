import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/services/layout_service.dart';

/// Pita generasi horizontal di latar kanvas (warna selang-seling).
/// Label "GEN n" digambar terpisah sebagai overlay sticky (lihat
/// [tree_gen_labels.dart]) agar selalu terlihat saat pan/zoom.
class TreeBandPainter extends CustomPainter {
  final TreeLayout layout;
  final Offset origin;

  TreeBandPainter({required this.layout, required this.origin});

  @override
  void paint(Canvas canvas, Size size) {
    if (layout.generations.isEmpty) return;
    final maxGen =
        layout.generations.values.reduce((a, b) => a > b ? a : b);
    const pad = 18.0;
    final h = layout.nodeSize.height + pad * 2;

    for (var g = 0; g <= maxGen; g++) {
      if (g.isOdd) continue;
      final top = g * LayoutService.stepY + origin.dy - pad;
      canvas.drawRect(
        Rect.fromLTWH(0, top, size.width, h),
        Paint()..color = AppColors.heritage.withValues(alpha: 0.05),
      );
    }
  }

  @override
  bool shouldRepaint(covariant TreeBandPainter old) =>
      old.layout != layout || old.origin != origin;
}
