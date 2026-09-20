import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/enums.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/relationship_model.dart';
import '../../domain/entities/family_graph.dart';
import '../../domain/services/layout_service.dart';

/// Menggambar relasi gaya silsilah klasik:
/// - Pasangan menikah: garis solid (ochre); cerai: pudar putus-putus + "CERAI".
/// - Turunan: **palang** — batang turun dari titik tengah garis pernikahan
///   (atau bawah node orang tua tunggal) ke palang horizontal; tiap anak
///   menggantung di bawahnya. Kandung = solid, angkat = putus-putus.
class TreeEdgePainter extends CustomPainter {
  final TreeLayout layout;
  final FamilyGraph graph;
  final Offset origin;

  TreeEdgePainter({
    required this.layout,
    required this.graph,
    required this.origin,
  });

  static const Color _lineColor = Color(0xFF8C8069);

  Size get _node => layout.nodeSize;

  double? _centerX(String id) {
    final p = layout.positions[id];
    if (p == null) return null;
    return p.dx + origin.dx + _node.width / 2;
  }

  double _top(String id) => layout.positions[id]!.dy + origin.dy;

  Offset? _avatarCenter(String id) {
    final x = _centerX(id);
    if (x == null) return null;
    return Offset(x, _top(id) + LayoutService.avatarCenterY);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 1) Garis pasangan.
    for (final r in graph.relationships) {
      if (r.type != RelationshipType.spouse) continue;
      final a = _avatarCenter(r.fromMemberId);
      final b = _avatarCenter(r.toMemberId);
      if (a != null && b != null) _paintSpouse(canvas, a, b, r);
    }

    // 2) Turunan, dikelompokkan per (set orang tua, tipe).
    final groups = <String, _ParentGroup>{};
    for (final child in graph.members) {
      final edges = graph.parentEdgesOf(child.id);
      if (edges.isEmpty) continue;
      final parentIds = edges.map((e) => e.fromMemberId).toList()..sort();
      final adoptive =
          edges.every((e) => e.type == RelationshipType.parentAdoptive);
      final key = '${parentIds.join('|')}#${adoptive ? 'A' : 'B'}';
      groups
          .putIfAbsent(
              key, () => _ParentGroup(parentIds: parentIds, adoptive: adoptive))
          .childIds
          .add(child.id);
    }

    for (final g in groups.values) {
      _paintGroup(canvas, g);
    }
  }

  void _paintGroup(Canvas canvas, _ParentGroup g) {
    final paint = Paint()
      ..color = _lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Titik atas tiap anak.
    final childTops = <Offset>[];
    for (final c in g.childIds) {
      final cx = _centerX(c);
      if (cx == null) continue;
      childTops.add(Offset(cx, _top(c) + 4));
    }
    if (childTops.isEmpty) return;

    // Titik asal batang.
    Offset? origin;
    if (g.parentIds.length == 2 &&
        graph.areSpouses(g.parentIds[0], g.parentIds[1])) {
      final a = _avatarCenter(g.parentIds[0]);
      final b = _avatarCenter(g.parentIds[1]);
      if (a != null && b != null) {
        origin = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
      }
    } else if (g.parentIds.length == 1) {
      final x = _centerX(g.parentIds.first);
      if (x != null) origin = Offset(x, _top(g.parentIds.first) + _node.height - 6);
    }

    // Fallback: 2 orang tua bukan pasangan → garis individual.
    if (origin == null) {
      for (final c in g.childIds) {
        for (final p in g.parentIds) {
          _paintParentCurve(canvas, p, c, dashed: g.adoptive);
        }
      }
      return;
    }

    // Geometri palang.
    final childXs = childTops.map((o) => o.dx).toList();
    final minChildTopY = childTops.map((o) => o.dy).reduce(math.min);
    final busY = minChildTopY - 22;
    final minX = math.min(origin.dx, childXs.reduce(math.min));
    final maxX = math.max(origin.dx, childXs.reduce(math.max));

    final path = Path()
      // batang
      ..moveTo(origin.dx, origin.dy)
      ..lineTo(origin.dx, busY)
      // palang horizontal
      ..moveTo(minX, busY)
      ..lineTo(maxX, busY);
    // tetesan ke tiap anak
    for (final c in childTops) {
      path
        ..moveTo(c.dx, busY)
        ..lineTo(c.dx, c.dy);
    }

    if (g.adoptive) {
      _dashed(canvas, path, paint);
    } else {
      canvas.drawPath(path, paint);
    }
  }

  /// Kurva-S tunggal orang tua → anak (fallback non-pasangan).
  void _paintParentCurve(Canvas canvas, String parentId, String childId,
      {required bool dashed}) {
    final px = _centerX(parentId);
    final cx = _centerX(childId);
    if (px == null || cx == null) return;
    final paint = Paint()
      ..color = _lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final from = Offset(px, _top(parentId) + _node.height - 6);
    final to = Offset(cx, _top(childId) + 4);
    final midY = (from.dy + to.dy) / 2;
    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..cubicTo(from.dx, midY, to.dx, midY, to.dx, to.dy);
    dashed ? _dashed(canvas, path, paint) : canvas.drawPath(path, paint);
  }

  void _paintSpouse(Canvas canvas, Offset a, Offset b, RelationshipModel r) {
    final divorced = r.status == RelationshipStatus.divorced;
    final paint = Paint()
      ..color = divorced ? AppColors.inkFaint : AppColors.heritage
      ..strokeWidth = divorced ? 2 : 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (divorced) {
      _dashed(canvas, Path()..moveTo(a.dx, a.dy)..lineTo(b.dx, b.dy), paint);
      _label(canvas, Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2), 'CERAI');
    } else {
      canvas.drawLine(a, b, paint);
    }
  }

  void _label(Canvas canvas, Offset center, String text) {
    final tp = TextPainter(
      text: TextSpan(
          text: text,
          style: AppTheme.sans(
              size: 9, weight: FontWeight.w700, color: AppColors.inkSoft)),
      textDirection: TextDirection.ltr,
    )..layout();
    const padH = 6.0, padV = 2.0;
    final rect = Rect.fromCenter(
      center: center,
      width: tp.width + padH * 2,
      height: tp.height + padV * 2,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6));
    canvas.drawRRect(rrect, Paint()..color = AppColors.surfaceSunk);
    canvas.drawRRect(
        rrect,
        Paint()
          ..color = AppColors.border
          ..style = PaintingStyle.stroke);
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  void _dashed(Canvas canvas, Path path, Paint paint,
      {double dash = 6, double gap = 4}) {
    for (final metric in path.computeMetrics()) {
      var dist = 0.0;
      while (dist < metric.length) {
        final next = dist + dash;
        canvas.drawPath(
            metric.extractPath(dist, next.clamp(0, metric.length)), paint);
        dist = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant TreeEdgePainter old) =>
      old.graph != graph || old.layout != layout || old.origin != origin;
}

class _ParentGroup {
  final List<String> parentIds;
  final bool adoptive;
  final List<String> childIds = [];
  _ParentGroup({required this.parentIds, required this.adoptive});
}
