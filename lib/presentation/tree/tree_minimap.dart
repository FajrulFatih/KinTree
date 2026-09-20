import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/constants/enums.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/member_model.dart';
import '../../domain/services/layout_service.dart';

/// Minimap kecil: titik node (warna gender) + kotak viewport yang bergerak
/// mengikuti pan/zoom kanvas.
class TreeMinimap extends StatelessWidget {
  final TransformationController controller;
  final TreeLayout layout;
  final List<MemberModel> members;
  final Offset origin;
  final Size canvasSize;
  final Size viewport;

  const TreeMinimap({
    super.key,
    required this.controller,
    required this.layout,
    required this.members,
    required this.origin,
    required this.canvasSize,
    required this.viewport,
  });

  static const Size _box = Size(124, 84);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _box.width,
      height: _box.height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
              color: Color(0x222B2117), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => CustomPaint(
          painter: _MinimapPainter(
            matrix: controller.value,
            layout: layout,
            members: members,
            origin: origin,
            canvasSize: canvasSize,
            viewport: viewport,
          ),
        ),
      ),
    );
  }
}

class _MinimapPainter extends CustomPainter {
  final Matrix4 matrix;
  final TreeLayout layout;
  final List<MemberModel> members;
  final Offset origin;
  final Size canvasSize;
  final Size viewport;

  _MinimapPainter({
    required this.matrix,
    required this.layout,
    required this.members,
    required this.origin,
    required this.canvasSize,
    required this.viewport,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (canvasSize.width <= 0 || canvasSize.height <= 0) return;
    const pad = 8.0;
    final s = min((size.width - pad * 2) / canvasSize.width,
        (size.height - pad * 2) / canvasSize.height);
    final dx = (size.width - canvasSize.width * s) / 2;
    final dy = (size.height - canvasSize.height * s) / 2;
    Offset map(Offset c) => Offset(dx + c.dx * s, dy + c.dy * s);

    // Titik node.
    for (final m in members) {
      final pos = layout.positions[m.id];
      if (pos == null) continue;
      final center = Offset(
        pos.dx + origin.dx + layout.nodeSize.width / 2,
        pos.dy + origin.dy + layout.nodeSize.height / 2,
      );
      canvas.drawCircle(
        map(center),
        2.2,
        Paint()..color = AppColors.genderColor(m.gender == Gender.male),
      );
    }

    // Kotak viewport (inverse transform layar → kanvas).
    try {
      final inv = Matrix4.inverted(matrix);
      final tl = MatrixUtils.transformPoint(inv, Offset.zero);
      final br = MatrixUtils.transformPoint(
          inv, Offset(viewport.width, viewport.height));
      final rect = Rect.fromPoints(map(tl), map(br));
      canvas.drawRect(
        rect,
        Paint()
          ..color = AppColors.brand
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      canvas.drawRect(
          rect, Paint()..color = AppColors.brand.withValues(alpha: 0.08));
    } catch (_) {
      // matrix tidak invertible — abaikan.
    }
  }

  @override
  bool shouldRepaint(covariant _MinimapPainter old) =>
      old.matrix != matrix || old.layout != layout;
}
