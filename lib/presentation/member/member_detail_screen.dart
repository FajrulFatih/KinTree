import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/enums.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_snackbar.dart';
import '../../data/models/member_model.dart';
import '../../providers/graph_providers.dart';
import '../../providers/supabase_providers.dart';
import '../relationship/relationship_form_screen.dart';
import '../widgets/confirm_dialog.dart';
import 'member_form_screen.dart';

/// Detail profil anggota (v2): avatar foto-forward, chip hubungan tappable.
class MemberDetailScreen extends ConsumerWidget {
  final String memberId;
  const MemberDetailScreen({super.key, required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final graph = ref.watch(familyGraphProvider);
    final member = graph.memberById(memberId);

    if (member == null) {
      return const Scaffold(
          body: Center(child: Text('Anggota tidak ditemukan')));
    }

    final dateFmt = DateFormat('d MMMM yyyy', 'id');
    final accent = AppColors.genderColor(member.gender == Gender.male);

    final spouses = graph.spousesOf(member.id);
    // Anak beserta tipe (untuk tag "angkat").
    final childRels = graph.relationships
        .where((r) =>
            r.type != RelationshipType.spouse && r.fromMemberId == member.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) =>
                  MemberFormScreen(familyId: member.familyId, existing: member),
            )),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            color: AppColors.danger,
            onPressed: () => _confirmDelete(context, ref, member),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
        children: [
          _Header(member: member, accent: accent),
          const SizedBox(height: 24),
          _DateCards(member: member, dateFmt: dateFmt),
          if (member.notes != null && member.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _NoteCard(text: member.notes!),
          ],
          const SizedBox(height: 24),
          Text('Hubungan', style: AppTheme.serif(size: 20)),
          const SizedBox(height: 12),
          _RelationGroup(
            icon: Icons.favorite_rounded,
            iconColor: AppColors.female,
            label: 'Pasangan',
            children: [
              for (final id in spouses)
                if (graph.memberById(id) != null)
                  _RelationChip(member: graph.memberById(id)!),
            ],
          ),
          const SizedBox(height: 14),
          _RelationGroup(
            icon: Icons.child_care_rounded,
            iconColor: AppColors.heritage,
            label: 'Anak',
            children: [
              for (final r in childRels)
                if (graph.memberById(r.toMemberId) != null)
                  _RelationChip(
                    member: graph.memberById(r.toMemberId)!,
                    tag: r.type == RelationshipType.parentAdoptive
                        ? 'angkat'
                        : null,
                  ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) =>
              RelationshipFormScreen(familyId: member.familyId, fromMember: member),
        )),
        icon: const Icon(Icons.add_link_rounded),
        label: const Text('Hubungan'),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, MemberModel member) async {
    final ok = await showConfirmDialog(
      context,
      icon: Icons.delete_outline_rounded,
      accent: AppColors.danger,
      title: 'Hapus anggota?',
      content: Text.rich(
        TextSpan(children: [
          emphasis(member.fullName),
          plain(
              ' akan dihapus beserta semua relasinya. Tindakan ini tidak bisa dibatalkan.'),
        ]),
        textAlign: TextAlign.center,
      ),
      confirmLabel: 'Hapus',
      confirmIcon: Icons.delete_outline_rounded,
      confirmColor: AppColors.danger,
    );
    if (!ok) return;
    await ref.read(memberRepositoryProvider).delete(member.id);
    // Write-through ke cache agar node hilang seketika.
    await ref.read(cacheRepositoryProvider).deleteMember(member.id);
    if (context.mounted) Navigator.of(context).pop();
    showAppSnack('Anggota "${member.fullName}" dihapus');
  }
}

class _Header extends StatelessWidget {
  final MemberModel member;
  final Color accent;
  const _Header({required this.member, required this.accent});

  String get _initials {
    final name = member.fullName.trim();
    if (name.isEmpty) return '?';
    final p = name.split(RegExp(r'\s+'));
    if (p.length == 1) return p.first.characters.first.toUpperCase();
    return (p.first.characters.first + p.last.characters.first).toUpperCase();
  }

  String _lifeline() {
    final b = member.birthDate?.year;
    if (!member.isAlive) {
      final d = member.deathDate?.year;
      if (b != null && d != null) return '$b — $d · ${d - b} tahun';
      if (b != null) return '$b';
      if (d != null) return '$d';
      return '';
    }
    return b != null ? 'Lahir $b' : '';
  }

  @override
  Widget build(BuildContext context) {
    final deceased = !member.isAlive;
    Widget avatar = Container(
      height: 96,
      width: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent, // isi solid
        image: member.photoUrl != null
            ? DecorationImage(
                image: NetworkImage(member.photoUrl!), fit: BoxFit.cover)
            : null,
      ),
      alignment: Alignment.center,
      child: member.photoUrl == null
          ? Text(_initials,
              style: AppTheme.serif(
                  size: 34, weight: FontWeight.w600, color: AppColors.page))
          : null,
    );
    if (deceased) {
      avatar = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.33, 0.33, 0.33, 0, 0, //
          0.33, 0.33, 0.33, 0, 0, //
          0.33, 0.33, 0.33, 0, 0, //
          0, 0, 0, 1, 0,
        ]),
        child: Opacity(opacity: 0.85, child: avatar),
      );
    }

    final subtitleParts = <String>[
      if (member.nickname != null && member.nickname!.isNotEmpty)
        '"${member.nickname}"',
      if (member.birthPlace != null && member.birthPlace!.isNotEmpty)
        member.birthPlace!,
    ];

    return Column(
      children: [
        avatar,
        const SizedBox(height: 8),
        if (deceased)
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('Alm.',
                style: AppTheme.sans(
                    size: 11, weight: FontWeight.w600, color: AppColors.page)),
          ),
        Text(member.fullName,
            textAlign: TextAlign.center,
            style: AppTheme.serif(size: 26, weight: FontWeight.w600)),
        if (subtitleParts.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(subtitleParts.join(' · '),
              style: AppTheme.sans(size: 14, color: AppColors.inkSoft)),
        ],
        if (_lifeline().isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(_lifeline(),
              style: AppTheme.sans(size: 13, color: AppColors.inkFaint)),
        ],
      ],
    );
  }
}

/// Kartu "Lahir" & "Wafat" berdampingan (gaya v2).
class _DateCards extends StatelessWidget {
  final MemberModel member;
  final DateFormat dateFmt;
  const _DateCards({required this.member, required this.dateFmt});

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      if (member.birthDate != null)
        _card('LAHIR', dateFmt.format(member.birthDate!)),
      if (!member.isAlive && member.deathDate != null)
        _card('WAFAT', dateFmt.format(member.deathDate!)),
    ];
    if (cards.isEmpty) return const SizedBox.shrink();
    // IntrinsicHeight memberi Row tinggi terbatas; tanpa ini `stretch` di dalam
    // ListView (tinggi tak terbatas) melempar "BoxConstraints forces an
    // infinite height" dan membuat body kosong.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: cards[i]),
          ],
        ],
      ),
    );
  }

  Widget _card(String label, String value) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: AppTheme.sans(
                    size: 11,
                    weight: FontWeight.w700,
                    color: AppColors.brand,
                    letterSpacing: 1)),
            const SizedBox(height: 6),
            Text(value, style: AppTheme.sans(size: 14)),
          ],
        ),
      );
}

class _NoteCard extends StatelessWidget {
  final String text;
  const _NoteCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Catatan',
              style: AppTheme.sans(size: 12, color: AppColors.inkFaint)),
          const SizedBox(height: 6),
          Text(text, style: AppTheme.sans(size: 14, height: 1.5)),
        ],
      ),
    );
  }
}

class _RelationGroup extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final List<Widget> children;
  const _RelationGroup({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 8),
            Text(label.toUpperCase(),
                style: AppTheme.sans(
                    size: 12,
                    weight: FontWeight.w700,
                    color: AppColors.inkSoft,
                    letterSpacing: 1)),
          ],
        ),
        const SizedBox(height: 8),
        if (children.isEmpty)
          Text('—', style: AppTheme.sans(color: AppColors.inkFaint))
        else
          Wrap(spacing: 8, runSpacing: 8, children: children),
      ],
    );
  }
}

class _RelationChip extends StatelessWidget {
  final MemberModel member;
  final String? tag;
  const _RelationChip({required this.member, this.tag});

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.genderColor(member.gender == Gender.male);
    final name = member.fullName.trim();
    final initial = name.isEmpty ? '?' : name.characters.first.toUpperCase();
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => MemberDetailScreen(memberId: member.id),
        )),
        child: Container(
          padding: const EdgeInsets.fromLTRB(6, 5, 12, 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 13,
                backgroundColor: accent.withValues(alpha: 0.16),
                foregroundImage: member.photoUrl != null
                    ? NetworkImage(member.photoUrl!)
                    : null,
                child: member.photoUrl == null
                    ? Text(initial,
                        style: AppTheme.sans(
                            size: 12,
                            weight: FontWeight.w600,
                            color: accent))
                    : null,
              ),
              const SizedBox(width: 8),
              Text(member.fullName,
                  style: AppTheme.sans(size: 13, weight: FontWeight.w500)),
              if (tag != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.heritage.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(tag!,
                      style: AppTheme.sans(
                          size: 10,
                          weight: FontWeight.w600,
                          color: AppColors.heritage)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
