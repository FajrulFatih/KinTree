import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/family_model.dart';
import '../../data/models/member_model.dart';
import '../../providers/graph_providers.dart';
import '../member/member_detail_screen.dart';
import '../member/member_form_screen.dart';
import '../widgets/node_card.dart';
import 'tree_band_painter.dart';
import 'tree_edge_painter.dart';
import 'tree_gen_labels.dart';
import 'tree_legend.dart';
import 'tree_minimap.dart';

/// Kanvas pohon silsilah v2: pita generasi, zoom, minimap, legenda,
/// pencarian fokus kamera, garis melengkung, node avatar solid.
class TreeScreen extends ConsumerStatefulWidget {
  final FamilyModel family;
  const TreeScreen({super.key, required this.family});

  @override
  ConsumerState<TreeScreen> createState() => _TreeScreenState();
}

class _TreeScreenState extends ConsumerState<TreeScreen> {
  final _tc = TransformationController();
  static const _origin = Offset(120, 28);
  String? _highlightedId;
  Size _viewport = Size.zero;

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  void _focusOn(String memberId) {
    final layout = ref.read(treeLayoutProvider);
    final pos = layout.positions[memberId];
    if (pos == null || _viewport == Size.zero) return;
    final nodeCenter = Offset(
      pos.dx + _origin.dx + layout.nodeSize.width / 2,
      pos.dy + _origin.dy + layout.nodeSize.height / 2,
    );
    _tc.value = Matrix4.identity()
      ..translateByDouble(_viewport.width / 2 - nodeCenter.dx,
          _viewport.height / 2 - nodeCenter.dy, 0, 1);
    setState(() => _highlightedId = memberId);
  }

  void _zoom(double factor) {
    if (_viewport == Size.zero) return;
    final c = Offset(_viewport.width / 2, _viewport.height / 2);
    final cur = _tc.value.getMaxScaleOnAxis();
    final target = (cur * factor).clamp(0.3, 2.5);
    final applied = target / cur;
    if ((applied - 1).abs() < 0.001) return;
    final m = Matrix4.identity()
      ..translateByDouble(c.dx, c.dy, 0, 1)
      ..scaleByDouble(applied, applied, 1, 1)
      ..translateByDouble(-c.dx, -c.dy, 0, 1);
    _tc.value = m.multiplied(_tc.value);
  }

  void _resetView() => _tc.value = Matrix4.identity();

  Future<void> _search() async {
    final members = ref.read(familyGraphProvider).members;
    final selected = await showSearch<MemberModel?>(
      context: context,
      delegate: _MemberSearchDelegate(members),
    );
    if (selected != null) _focusOn(selected.id);
  }

  @override
  Widget build(BuildContext context) {
    final graph = ref.watch(familyGraphProvider);
    final layout = ref.watch(treeLayoutProvider);
    final membersAsync = ref.watch(membersStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.family.familyName),
        actions: [
          IconButton(
            tooltip: 'Legenda',
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => showTreeLegend(context),
          ),
        ],
      ),
      body: membersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (_) {
          if (graph.isEmpty) return const _EmptyTreeHint();
          return LayoutBuilder(
            builder: (context, constraints) {
              _viewport = constraints.biggest;
              final canvas = Size(
                layout.canvasSize.width + _origin.dx,
                layout.canvasSize.height +
                    _origin.dy +
                    layout.nodeSize.height,
              );
              return Stack(
                children: [
                  InteractiveViewer(
                    transformationController: _tc,
                    constrained: false,
                    minScale: 0.3,
                    maxScale: 2.5,
                    boundaryMargin: const EdgeInsets.all(400),
                    child: SizedBox(
                      width: canvas.width,
                      height: canvas.height,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: RepaintBoundary(
                              child: CustomPaint(
                                painter: TreeBandPainter(
                                    layout: layout, origin: _origin),
                                foregroundPainter: TreeEdgePainter(
                                  layout: layout,
                                  graph: graph,
                                  origin: _origin,
                                ),
                              ),
                            ),
                          ),
                          ...graph.members.map((m) {
                            final pos = layout.positions[m.id];
                            if (pos == null) return const SizedBox.shrink();
                            return Positioned(
                              left: pos.dx + _origin.dx,
                              top: pos.dy + _origin.dy,
                              width: layout.nodeSize.width,
                              height: layout.nodeSize.height,
                              child: RepaintBoundary(
                                child: NodeCard(
                                  member: m,
                                  highlighted: m.id == _highlightedId,
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          MemberDetailScreen(memberId: m.id),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  // Label generasi sticky (tepi kiri).
                  Positioned.fill(
                    child: TreeGenLabels(
                      controller: _tc,
                      layout: layout,
                      origin: _origin,
                      viewport: _viewport,
                    ),
                  ),
                  // Search + tombol kode undangan.
                  Positioned(
                    top: 12,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        Expanded(child: _SearchPill(onTap: _search)),
                        const SizedBox(width: 10),
                        _SquareButton(
                          icon: Icons.qr_code_rounded,
                          onTap: () => _showInvite(context),
                        ),
                      ],
                    ),
                  ),
                  // Minimap (kiri bawah).
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: TreeMinimap(
                      controller: _tc,
                      layout: layout,
                      members: graph.members,
                      origin: _origin,
                      canvasSize: canvas,
                      viewport: _viewport,
                    ),
                  ),
                  // Kontrol zoom (kanan bawah, di atas FAB).
                  Positioned(
                    right: 16,
                    bottom: 88,
                    child: _ZoomControls(
                      onIn: () => _zoom(1.25),
                      onOut: () => _zoom(0.8),
                      onReset: _resetView,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => MemberFormScreen(
            familyId: widget.family.id,
            familyName: widget.family.familyName,
          ),
        )),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Anggota'),
      ),
    );
  }

  void _showInvite(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Kode Undangan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bagikan kode ini agar kerabat bisa bergabung:',
                style: AppTheme.sans(size: 14, color: AppColors.inkSoft)),
            const SizedBox(height: 16),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceSunk,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(widget.family.inviteCode,
                  style: AppTheme.serif(size: 30, weight: FontWeight.w700)
                      .copyWith(letterSpacing: 6)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(
                  ClipboardData(text: widget.family.inviteCode));
              Navigator.pop(context);
            },
            child: const Text('Salin & tutup'),
          ),
        ],
      ),
    );
  }
}

class _SearchPill extends StatelessWidget {
  final VoidCallback onTap;
  const _SearchPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(30),
      elevation: 1,
      shadowColor: const Color(0x222B2117),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded,
                  size: 20, color: AppColors.inkFaint),
              const SizedBox(width: 10),
              Text('Cari anggota…',
                  style:
                      AppTheme.sans(size: 14, color: AppColors.inkFaint)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SquareButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SquareButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      elevation: 1,
      shadowColor: const Color(0x222B2117),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, size: 22, color: AppColors.ink),
        ),
      ),
    );
  }
}

class _ZoomControls extends StatelessWidget {
  final VoidCallback onIn, onOut, onReset;
  const _ZoomControls(
      {required this.onIn, required this.onOut, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
              color: Color(0x222B2117), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(Icons.add_rounded, onIn),
          const Divider(height: 1, indent: 8, endIndent: 8),
          _btn(Icons.remove_rounded, onOut),
          const Divider(height: 1, indent: 8, endIndent: 8),
          _btn(Icons.center_focus_strong_rounded, onReset),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: AppColors.ink, size: 22),
        ),
      );
}

class _EmptyTreeHint extends StatelessWidget {
  const _EmptyTreeHint();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.park_rounded,
                size: 72, color: AppColors.inkFaint),
            const SizedBox(height: 16),
            Text(
              'Pohon masih kosong.\nTekan "Anggota" untuk menambah orang pertama.',
              textAlign: TextAlign.center,
              style: AppTheme.sans(color: AppColors.inkSoft, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberSearchDelegate extends SearchDelegate<MemberModel?> {
  final List<MemberModel> members;
  _MemberSearchDelegate(this.members);

  @override
  String get searchFieldLabel => 'Cari anggota…';

  @override
  List<Widget> buildActions(BuildContext context) =>
      [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _list(context);

  @override
  Widget buildSuggestions(BuildContext context) => _list(context);

  Widget _list(BuildContext context) {
    final q = query.toLowerCase();
    final results =
        members.where((m) => m.fullName.toLowerCase().contains(q)).toList();
    return ListView(
      children: results
          .map((m) => ListTile(
                leading: const Icon(Icons.person_outline_rounded),
                title: Text(m.fullName),
                onTap: () => close(context, m),
              ))
          .toList(),
    );
  }
}
