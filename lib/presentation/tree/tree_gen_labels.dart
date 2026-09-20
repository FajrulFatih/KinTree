import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/services/layout_service.dart';

/// Overlay label generasi ("GEN I/II/III") yang menempel di tepi kiri layar
/// dan bergerak vertikal mengikuti pita generasinya saat pan/zoom — sehingga
/// selalu terlihat (tidak ikut tergeser horizontal seperti saat digambar di
/// dalam kanvas).
class TreeGenLabels extends StatelessWidget {
  final TransformationController controller;
  final TreeLayout layout;
  final Offset origin;
  final Size viewport;

  const TreeGenLabels({
    super.key,
    required this.controller,
    required this.layout,
    required this.origin,
    required this.viewport,
  });

  static const _roman = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII'];

  @override
  Widget build(BuildContext context) {
    if (layout.generations.isEmpty) return const SizedBox.shrink();
    final maxGen =
        layout.generations.values.reduce((a, b) => a > b ? a : b);

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final m = controller.value;
          final scaleY = m.getMaxScaleOnAxis();
          final transY = m.getTranslation().y;
          final rowH = layout.nodeSize.height * scaleY;

          final pills = <Widget>[];
          for (var g = 0; g <= maxGen; g++) {
            final canvasY = g * LayoutService.stepY + origin.dy;
            final screenY = canvasY * scaleY + transY;
            // Tampilkan jika baris generasi ini menyentuh viewport.
            if (screenY + rowH < 0 || screenY > viewport.height) continue;
            final top = screenY.clamp(8.0, viewport.height - 36);
            pills.add(Positioned(
              left: 12,
              top: top,
              child: _pill('GEN ${g < _roman.length ? _roman[g] : g + 1}'),
            ));
          }
          return Stack(children: pills);
        },
      ),
    );
  }

  Widget _pill(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(text,
            style: AppTheme.sans(
                size: 11,
                weight: FontWeight.w700,
                color: AppColors.inkFaint,
                letterSpacing: 1)),
      );
}
