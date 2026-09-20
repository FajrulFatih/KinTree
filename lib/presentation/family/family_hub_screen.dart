import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_snackbar.dart';
import '../../core/utils/error_message.dart';
import '../../data/models/family_model.dart';
import '../../providers/family_providers.dart';
import '../../providers/supabase_providers.dart';
import '../tree/tree_screen.dart';
import '../widgets/confirm_dialog.dart';

/// Hub setelah login: pilih grup, atau buat/gabung grup baru.
class FamilyHubScreen extends ConsumerWidget {
  const FamilyHubScreen({super.key});

  static const _accents = [
    AppColors.brand,
    AppColors.heritage,
    AppColors.male,
    AppColors.female,
  ];

  void _open(BuildContext context, WidgetRef ref, FamilyModel family) {
    ref.read(activeFamilyProvider.notifier).select(family.id);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TreeScreen(family: family)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final families = ref.watch(myFamiliesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keluarga'),
        actions: [
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _confirmLogout(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(myFamiliesProvider.future),
        child: families.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => _ErrorView(
            message: friendlyError(e),
            onRetry: () => ref.invalidate(myFamiliesProvider),
          ),
          data: (list) {
            if (list.isEmpty) return const _EmptyHint();
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              itemCount: list.length,
              separatorBuilder: (_, i) => const SizedBox(height: 14),
              itemBuilder: (_, i) => _FamilyCard(
                family: list[i],
                accent: _accents[list[i].familyName.hashCode.abs() % 4],
                onOpen: () => _open(context, ref, list[i]),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateJoinSheet(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Grup'),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final ok = await showConfirmDialog(
      context,
      icon: Icons.logout_rounded,
      accent: AppColors.heritage,
      title: 'Keluar dari akun?',
      content: const Text(
        'Kamu perlu masuk lagi dengan email untuk membuka silsilah keluarga.',
        textAlign: TextAlign.center,
      ),
      confirmLabel: 'Keluar',
      confirmIcon: Icons.logout_rounded,
      confirmColor: AppColors.heritage,
    );
    if (ok) {
      await ref.read(authRepositoryProvider).signOut();
      showAppSnack('Berhasil keluar');
    }
  }

  void _showCreateJoinSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.page,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: _CreateJoinSheet(onDone: () => ref.invalidate(myFamiliesProvider)),
      ),
    );
  }
}

class _FamilyCard extends StatelessWidget {
  final FamilyModel family;
  final Color accent;
  final VoidCallback onOpen;
  const _FamilyCard(
      {required this.family, required this.accent, required this.onOpen});

  String get _initials {
    final parts = family.familyName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts[1].characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onOpen,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(_initials,
                        style: AppTheme.serif(
                            size: 19, weight: FontWeight.w600, color: accent)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(family.familyName,
                            style: AppTheme.serif(
                                size: 18, weight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text('Ketuk untuk membuka silsilah',
                            style: AppTheme.sans(
                                size: 13, color: AppColors.inkSoft)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.inkFaint),
                ],
              ),
            ),
          ),
          _InviteTicket(code: family.inviteCode),
        ],
      ),
    );
  }
}

/// Kode undangan bergaya tiket dengan takik di sisi.
class _InviteTicket extends StatelessWidget {
  final String code;
  const _InviteTicket({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSunk,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.confirmation_number_outlined,
              size: 20, color: AppColors.heritage),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kode undangan',
                  style:
                      AppTheme.sans(size: 11, color: AppColors.inkFaint)),
              Text(code,
                  style: AppTheme.sans(
                      size: 16,
                      weight: FontWeight.w700,
                      letterSpacing: 3,
                      color: AppColors.ink)),
            ],
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Salin kode',
            icon: const Icon(Icons.content_copy_rounded, size: 18),
            color: AppColors.inkSoft,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Kode "$code" disalin')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CreateJoinSheet extends ConsumerStatefulWidget {
  final VoidCallback onDone;
  const _CreateJoinSheet({required this.onDone});

  @override
  ConsumerState<_CreateJoinSheet> createState() => _CreateJoinSheetState();
}

class _CreateJoinSheetState extends ConsumerState<_CreateJoinSheet> {
  final _name = TextEditingController();
  final _code = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      if (!mounted) return;
      widget.onDone();
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(friendlyError(e))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(familyRepositoryProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
          Text('Buat grup keluarga baru',
              style: AppTheme.sans(size: 16, weight: FontWeight.w600)),
          const SizedBox(height: 10),
          TextField(
            controller: _name,
            decoration: const InputDecoration(
                labelText: 'Nama keluarga', hintText: 'cth. Bani Sastro'),
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: _busy
                ? null
                : () => _run(() => repo.createFamily(_name.text.trim())),
            child: const Text('Buat'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('atau',
                      style: AppTheme.sans(
                          size: 13, color: AppColors.inkFaint)),
                ),
                const Expanded(child: Divider()),
              ],
            ),
          ),
          Text('Gabung dengan kode undangan',
              style: AppTheme.sans(size: 16, weight: FontWeight.w600)),
          const SizedBox(height: 10),
          TextField(
            controller: _code,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
                labelText: 'Kode undangan', hintText: 'cth. AB3D9K'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: _busy
                ? null
                : () => _run(() => repo.joinFamily(_code.text.trim())),
            child: const Text('Gabung'),
          ),
          if (_busy) ...[
            const SizedBox(height: 16),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 120),
        const Icon(Icons.family_restroom_rounded,
            size: 72, color: AppColors.inkFaint),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'Belum ada grup keluarga.\nBuat baru atau gabung dengan kode undangan.',
            textAlign: TextAlign.center,
            style: AppTheme.sans(color: AppColors.inkSoft, height: 1.5),
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 120),
        const Icon(Icons.error_outline_rounded,
            size: 56, color: AppColors.danger),
        const SizedBox(height: 12),
        Center(
            child: Text(message,
                textAlign: TextAlign.center,
                style: AppTheme.sans(color: AppColors.inkSoft))),
        const SizedBox(height: 12),
        Center(
          child: OutlinedButton(
            onPressed: onRetry,
            child: const Text('Coba lagi'),
          ),
        ),
      ],
    );
  }
}
