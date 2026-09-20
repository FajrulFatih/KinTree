import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/enums.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_snackbar.dart';
import '../../core/utils/error_message.dart';
import '../../data/models/member_model.dart';
import '../../data/models/relationship_model.dart';
import '../../data/repositories/relationship_repository.dart';
import '../../providers/graph_providers.dart';
import '../../providers/supabase_providers.dart';

/// Jenis hubungan tingkat-UI (dipetakan ke aksi saat simpan).
enum _RelKind {
  spouse('Pasangan'),
  childBiological('Anak (kandung)'),
  childAdoptive('Anak (angkat)'),
  parentBiological('Orang tua (kandung)'),
  parentAdoptive('Orang tua (angkat)'),
  sibling('Saudara');

  final String label;
  const _RelKind(this.label);

  bool get isChild =>
      this == _RelKind.childBiological || this == _RelKind.childAdoptive;
  bool get isParent =>
      this == _RelKind.parentBiological || this == _RelKind.parentAdoptive;

  RelationshipType get parentType =>
      (this == _RelKind.childAdoptive || this == _RelKind.parentAdoptive)
          ? RelationshipType.parentAdoptive
          : RelationshipType.parentBiological;
}

/// Form menambah hubungan dari [fromMember] ke anggota lain:
/// - Pasangan
/// - Anak (kandung/angkat) → [fromMember] jadi orang tua; bisa pilih orang tua kedua.
/// - Orang tua (kandung/angkat) → [fromMember] jadi anak; bisa pilih orang tua kedua.
/// - Saudara → menyalin orang tua [fromMember] ke target (berbagi orang tua).
class RelationshipFormScreen extends ConsumerStatefulWidget {
  final String familyId;
  final MemberModel fromMember;

  const RelationshipFormScreen({
    super.key,
    required this.familyId,
    required this.fromMember,
  });

  @override
  ConsumerState<RelationshipFormScreen> createState() =>
      _RelationshipFormScreenState();
}

class _RelationshipFormScreenState
    extends ConsumerState<RelationshipFormScreen> {
  _RelKind _kind = _RelKind.spouse;
  RelationshipStatus _status = RelationshipStatus.married;
  String? _targetId;
  String? _coParentId; // orang tua kedua (pasangan) — untuk Anak/Orang tua
  bool _saving = false;

  Future<void> _save(List<RelationshipModel> referenceParentEdges) async {
    if (_targetId == null) return;
    setState(() => _saving = true);
    final repo = ref.read(relationshipRepositoryProvider);
    final cache = ref.read(cacheRepositoryProvider);

    try {
      final toCreate = <RelationshipModel>[];

      RelationshipModel parentEdge(String parentId, String childId) =>
          RelationshipModel(
            id: '',
            familyId: widget.familyId,
            fromMemberId: parentId,
            toMemberId: childId,
            type: _kind.parentType,
          );

      switch (_kind) {
        case _RelKind.spouse:
          final order = await repo.nextMarriageOrder(
              widget.familyId, widget.fromMember.id);
          toCreate.add(RelationshipModel(
            id: '',
            familyId: widget.familyId,
            fromMemberId: widget.fromMember.id,
            toMemberId: _targetId!,
            type: RelationshipType.spouse,
            status: _status,
            marriageOrder: order,
          ));
        case _RelKind.childBiological:
        case _RelKind.childAdoptive:
          // fromMember = orang tua, target = anak.
          toCreate.add(parentEdge(widget.fromMember.id, _targetId!));
          if (_coParentId != null) {
            toCreate.add(parentEdge(_coParentId!, _targetId!));
          }
        case _RelKind.parentBiological:
        case _RelKind.parentAdoptive:
          // target = orang tua, fromMember = anak.
          toCreate.add(parentEdge(_targetId!, widget.fromMember.id));
          if (_coParentId != null) {
            toCreate.add(parentEdge(_coParentId!, widget.fromMember.id));
          }
        case _RelKind.sibling:
          toCreate.addAll(RelationshipRepository.siblingEdgesFrom(
            referenceParentEdges: referenceParentEdges,
            familyId: widget.familyId,
            targetId: _targetId!,
          ));
      }

      for (final rel in toCreate) {
        final created = await repo.create(rel);
        await cache.upsertRelationship(created); // write-through
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      showAppSnack(_kind == _RelKind.sibling
          ? 'Saudara ditautkan'
          : 'Hubungan ditambahkan');
    } catch (e) {
      if (!mounted) return;
      showAppSnack(friendlyError(e), success: false);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final graph = ref.watch(familyGraphProvider);
    final from = widget.fromMember;

    final candidates = graph.members.where((m) => m.id != from.id).toList();

    // Sumber "orang tua kedua":
    // - Anak  → pasangan dari fromMember.
    // - Orang tua → pasangan dari orang tua yang dipilih (target).
    final coParentSourceId = _kind.isParent ? _targetId : from.id;
    final coParents = (coParentSourceId == null)
        ? <MemberModel>[]
        : graph
            .spousesOf(coParentSourceId)
            .map(graph.memberById)
            .whereType<MemberModel>()
            .where((m) => m.id != _targetId) // jangan tawarkan target sendiri
            .toList();

    final parentEdges = graph.parentEdgesOf(from.id);
    final siblingBlocked = _kind == _RelKind.sibling && parentEdges.isEmpty;

    final targetLabel = switch (_kind) {
      _RelKind.spouse => 'Pasangan dari ${from.fullName}',
      _RelKind.sibling => 'Saudara dari ${from.fullName}',
      _ when _kind.isParent => 'Orang tua dari ${from.fullName}',
      _ => 'Anak dari ${from.fullName}',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Hubungan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Anggota: ${from.fullName}',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          DropdownButtonFormField<_RelKind>(
            initialValue: _kind,
            decoration: const InputDecoration(labelText: 'Jenis hubungan'),
            items: _RelKind.values
                .map((k) => DropdownMenuItem(value: k, child: Text(k.label)))
                .toList(),
            onChanged: (k) => setState(() {
              _kind = k ?? _RelKind.spouse;
              _coParentId = null;
            }),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _targetId,
            isExpanded: true,
            decoration: InputDecoration(labelText: targetLabel),
            items: candidates
                .map((m) =>
                    DropdownMenuItem(value: m.id, child: Text(m.fullName)))
                .toList(),
            onChanged: (id) => setState(() {
              _targetId = id;
              _coParentId = null; // reset; sumber pasangan bisa berubah
            }),
          ),

          // Orang tua kedua (pasangan) — untuk Anak / Orang tua.
          if (_kind.isChild || _kind.isParent) ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              initialValue: _coParentId,
              isExpanded: true,
              decoration: const InputDecoration(
                  labelText: 'Orang tua kedua (pasangan)'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('— tanpa pasangan (orang tua tunggal)'),
                ),
                ...coParents.map((m) => DropdownMenuItem<String?>(
                    value: m.id, child: Text(m.fullName))),
              ],
              onChanged: (id) => setState(() => _coParentId = id),
            ),
            const SizedBox(height: 8),
            Text(
              _kind.isParent
                  ? (_targetId == null
                      ? 'Pilih orang tua dulu; pasangannya (bila ada) akan muncul sebagai orang tua kedua.'
                      : (coParents.isEmpty
                          ? 'Orang tua ini belum punya pasangan tercatat — anak akan terhubung ke satu orang tua.'
                          : 'Pilih pasangan agar terhubung ke kedua orang tua (satu garis turunan).'))
                  : (coParents.isEmpty
                      ? '${from.fullName} belum punya pasangan tercatat — anak akan terhubung ke satu orang tua.'
                      : 'Pilih pasangan agar anak langsung terhubung ke kedua orang tua (satu garis turunan).'),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],

          // Status pernikahan (untuk Pasangan).
          if (_kind == _RelKind.spouse) ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<RelationshipStatus>(
              initialValue: _status,
              decoration:
                  const InputDecoration(labelText: 'Status pernikahan'),
              items: RelationshipStatus.values
                  .map((s) =>
                      DropdownMenuItem(value: s, child: Text(s.label)))
                  .toList(),
              onChanged: (s) =>
                  setState(() => _status = s ?? RelationshipStatus.married),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pernikahan ke-N dihitung otomatis (mendukung poligami / '
              'pernikahan berulang).',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],

          if (_kind == _RelKind.childAdoptive ||
              _kind == _RelKind.parentAdoptive) ...[
            const SizedBox(height: 8),
            const Text(
              'Hubungan adopsi digambar dengan garis putus-putus pada pohon.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],

          // Peringatan saudara tanpa orang tua.
          if (siblingBlocked) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.danger.withValues(alpha: 0.4)),
              ),
              child: Text(
                '${from.fullName} belum punya orang tua tercatat. Tambahkan orang tua dulu agar saudara bisa ditautkan (saudara = berbagi orang tua yang sama).',
                style: const TextStyle(fontSize: 13, color: AppColors.danger),
              ),
            ),
          ],

          const SizedBox(height: 24),
          FilledButton(
            onPressed: (_saving || _targetId == null || siblingBlocked)
                ? null
                : () => _save(parentEdges),
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Simpan hubungan'),
          ),
        ],
      ),
    );
  }
}
