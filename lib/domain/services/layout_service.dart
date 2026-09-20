import 'dart:math';
import 'dart:ui';

import '../entities/family_graph.dart';

/// Hasil tata letak: posisi tiap node + ukuran kanvas total.
class TreeLayout {
  final Map<String, Offset> positions; // pusat-atas kartu node
  final Map<String, int> generations;
  final Size canvasSize;
  final Size nodeSize;

  const TreeLayout({
    required this.positions,
    required this.generations,
    required this.canvasSize,
    required this.nodeSize,
  });
}

/// Menghitung koordinat simpul mengikuti strategi dari design.md §3:
/// generasi pada sumbu-Y, pasangan berdampingan pada sumbu-X, dan
/// orang tua dipusatkan di atas rentang anak-anaknya.
class LayoutService {
  static const double stepX = 170; // jarak horizontal antar slot
  static const double stepY = 190; // jarak vertikal antar generasi
  static const Size nodeSize = Size(140, 120);

  /// Jarak vertikal pusat avatar dari sisi atas node (untuk penambatan garis).
  static const double avatarCenterY = 34;

  TreeLayout build(FamilyGraph graph) {
    final positions = <String, Offset>{};
    final generations = <String, int>{};
    final visited = <String>{};
    double cursor = 0;

    double place(String id, int gen) {
      if (visited.contains(id)) return positions[id]!.dx;
      visited.add(id);
      generations[id] = gen;

      final partners =
          graph.spousesOf(id).where((s) => !visited.contains(s)).toList();

      final childIds = <String>{};
      for (final p in [id, ...partners]) {
        childIds.addAll(graph.childrenOf(p));
      }
      final unvisitedChildren =
          childIds.where((c) => !visited.contains(c)).toList();

      double x;
      if (unvisitedChildren.isEmpty) {
        x = cursor;
        cursor += stepX;
      } else {
        final xs = unvisitedChildren.map((c) => place(c, gen + 1)).toList();
        x = (xs.reduce(min) + xs.reduce(max)) / 2;
      }
      positions[id] = Offset(x, gen * stepY);

      // Tempatkan pasangan tepat di sebelah kanan.
      var partnerX = x;
      for (final p in partners) {
        visited.add(p);
        generations[p] = gen;
        partnerX += stepX;
        positions[p] = Offset(partnerX, gen * stepY);
      }
      cursor = max(cursor, partnerX + stepX);
      return x;
    }

    for (final root in graph.roots) {
      place(root.id, 0);
    }
    // Anggota tak terhubung (tanpa relasi) tetap ditampilkan.
    for (final m in graph.members) {
      if (!visited.contains(m.id)) place(m.id, 0);
    }

    final maxX = positions.values.fold<double>(0, (a, o) => max(a, o.dx));
    final maxY = positions.values.fold<double>(0, (a, o) => max(a, o.dy));

    return TreeLayout(
      positions: positions,
      generations: generations,
      canvasSize: Size(maxX + stepX * 2, maxY + stepY),
      nodeSize: nodeSize,
    );
  }
}
