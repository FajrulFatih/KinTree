import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Menampilkan legenda pohon sebagai bottom sheet.
void showTreeLegend(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.page,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _LegendSheet(),
  );
}

class _LegendSheet extends StatelessWidget {
  const _LegendSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.borderStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text('Legenda pohon', style: AppTheme.serif(size: 20)),
          const SizedBox(height: 16),
          _line('Pasangan menikah', AppColors.heritage, dashed: false),
          _line('Cerai (pudar + label)', AppColors.inkFaint, dashed: true),
          _line('Orang tua kandung', const Color(0xFF8C8069), dashed: false),
          _line('Orang tua angkat', const Color(0xFF8C8069), dashed: true),
          const SizedBox(height: 8),
          Row(
            children: [
              _dot('Laki-laki', AppColors.male),
              const SizedBox(width: 24),
              _dot('Perempuan', AppColors.female),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              'Gender kini jadi aksen halus, bukan border kaku. Yang wafat ditandai foto teredam + tag "Alm.".',
              style: AppTheme.sans(
                  size: 13, color: AppColors.inkSoft, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(String label, Color color, {required bool dashed}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              height: 12,
              child: CustomPaint(
                  painter: _LinePainter(color: color, dashed: dashed)),
            ),
            const SizedBox(width: 14),
            Text(label, style: AppTheme.sans(size: 14)),
          ],
        ),
      );

  Widget _dot(String label, Color color) => Row(
        children: [
          Container(
            height: 16,
            width: 16,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(label, style: AppTheme.sans(size: 14)),
        ],
      );
}

class _LinePainter extends CustomPainter {
  final Color color;
  final bool dashed;
  _LinePainter({required this.color, required this.dashed});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final y = size.height / 2;
    if (!dashed) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    } else {
      var x = 0.0;
      while (x < size.width) {
        canvas.drawLine(Offset(x, y), Offset((x + 6).clamp(0, size.width), y), p);
        x += 10;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) =>
      old.color != color || old.dashed != dashed;
}
