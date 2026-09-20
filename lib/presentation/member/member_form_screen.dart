import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../core/constants/enums.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_snackbar.dart';
import '../../core/utils/error_message.dart';
import '../../data/models/member_model.dart';
import '../../providers/graph_providers.dart';
import '../../providers/supabase_providers.dart';
import '../widgets/confirm_dialog.dart';

/// Form tambah/edit anggota (v2): foto, toggle gender, tanggal, switch.
class MemberFormScreen extends ConsumerStatefulWidget {
  final String familyId;
  final MemberModel? existing;

  /// Nama grup (untuk dialog konfirmasi "Tambah anggota baru?").
  final String? familyName;

  const MemberFormScreen({
    super.key,
    required this.familyId,
    this.existing,
    this.familyName,
  });

  @override
  ConsumerState<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends ConsumerState<MemberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _first;
  late final TextEditingController _last;
  late final TextEditingController _nickname;
  late final TextEditingController _birthPlace;
  late final TextEditingController _notes;

  Gender _gender = Gender.male;
  DateTime? _birthDate;
  bool _isAlive = true;
  DateTime? _deathDate;
  Uint8List? _pickedPhoto;
  bool _saving = false;

  final _dateFmt = DateFormat('d MMMM yyyy', 'id');

  @override
  void initState() {
    super.initState();
    final m = widget.existing;
    _first = TextEditingController(text: m?.firstName);
    _last = TextEditingController(text: m?.lastName);
    _nickname = TextEditingController(text: m?.nickname);
    _birthPlace = TextEditingController(text: m?.birthPlace);
    _notes = TextEditingController(text: m?.notes);
    _gender = m?.gender ?? Gender.male;
    _birthDate = m?.birthDate;
    _isAlive = m?.isAlive ?? true;
    _deathDate = m?.deathDate;
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _nickname.dispose();
    _birthPlace.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() => _pickedPhoto = bytes);
  }

  Future<void> _pickDate({required bool isBirth}) async {
    final initial = (isBirth ? _birthDate : _deathDate) ?? DateTime(1980);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1850),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() {
      if (isBirth) {
        _birthDate = picked;
      } else {
        _deathDate = picked;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Konfirmasi saat menambah anggota BARU (bukan edit).
    if (widget.existing == null && widget.familyName != null) {
      final ok = await showConfirmDialog(
        context,
        icon: Icons.person_add_alt_1_rounded,
        accent: AppColors.brand,
        title: 'Tambah anggota baru?',
        content: Text.rich(
          TextSpan(children: [
            emphasis(_first.text.trim(), color: AppColors.brand),
            plain(' akan ditambahkan ke pohon '),
            emphasis(widget.familyName!, color: AppColors.heritage),
            plain('.'),
          ]),
          textAlign: TextAlign.center,
        ),
        confirmLabel: 'Tambah',
        confirmIcon: Icons.check_rounded,
        confirmColor: AppColors.brand,
      );
      if (!ok) return;
    }

    setState(() => _saving = true);
    final repo = ref.read(memberRepositoryProvider);
    try {
      final model = MemberModel(
        id: widget.existing?.id ?? '',
        familyId: widget.familyId,
        firstName: _first.text.trim(),
        lastName: _last.text.trim().isEmpty ? null : _last.text.trim(),
        nickname: _nickname.text.trim().isEmpty ? null : _nickname.text.trim(),
        gender: _gender,
        birthPlace:
            _birthPlace.text.trim().isEmpty ? null : _birthPlace.text.trim(),
        birthDate: _birthDate,
        isAlive: _isAlive,
        deathDate: _isAlive ? null : _deathDate,
        photoUrl: widget.existing?.photoUrl,
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      );

      var saved = await repo.upsert(model, id: widget.existing?.id);

      if (_pickedPhoto != null) {
        final url = await repo.uploadPhoto(
          familyId: widget.familyId,
          memberId: saved.id,
          bytes: _pickedPhoto!,
        );
        saved = await repo.upsert(
          MemberModel(
            id: saved.id,
            familyId: saved.familyId,
            firstName: saved.firstName,
            lastName: saved.lastName,
            nickname: saved.nickname,
            gender: saved.gender,
            birthPlace: saved.birthPlace,
            birthDate: saved.birthDate,
            isAlive: saved.isAlive,
            deathDate: saved.deathDate,
            photoUrl: url,
            notes: saved.notes,
          ),
          id: saved.id,
        );
      }

      // Write-through ke cache lokal agar UI langsung ter-update tanpa
      // bergantung pada Supabase Realtime.
      await ref.read(cacheRepositoryProvider).upsertMember(saved);

      if (!mounted) return;
      Navigator.of(context).pop();
      showAppSnack(widget.existing == null
          ? 'Anggota "${saved.fullName}" ditambahkan'
          : 'Perubahan "${saved.fullName}" disimpan');
    } catch (e) {
      if (!mounted) return;
      showAppSnack(friendlyError(e), success: false);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Anggota' : 'Tambah Anggota')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: _photoPicker()),
              const SizedBox(height: 24),
              _label('Nama depan *'),
              TextFormField(
                controller: _first,
                decoration: const InputDecoration(hintText: 'Budi'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              _label('Nama belakang'),
              TextFormField(
                controller: _last,
                decoration: const InputDecoration(hintText: 'Wijoyo'),
              ),
              const SizedBox(height: 16),
              _label('Nama panggilan'),
              TextFormField(
                controller: _nickname,
                decoration: const InputDecoration(hintText: 'Mbah Kakung'),
              ),
              const SizedBox(height: 16),
              _label('Jenis kelamin'),
              _GenderToggle(
                value: _gender,
                onChanged: (g) => setState(() => _gender = g),
              ),
              const SizedBox(height: 16),
              _label('Tempat lahir'),
              TextFormField(
                controller: _birthPlace,
                decoration: const InputDecoration(hintText: 'Yogyakarta'),
              ),
              const SizedBox(height: 16),
              _label('Tanggal lahir'),
              _DateTile(
                value: _birthDate == null ? null : _dateFmt.format(_birthDate!),
                onTap: () => _pickDate(isBirth: true),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceSunk,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: SwitchListTile(
                  title: Text('Masih hidup',
                      style: AppTheme.sans(size: 15, weight: FontWeight.w500)),
                  value: _isAlive,
                  activeThumbColor: AppColors.brand,
                  onChanged: (v) => setState(() => _isAlive = v),
                ),
              ),
              if (!_isAlive) ...[
                const SizedBox(height: 16),
                _label('Tanggal wafat'),
                _DateTile(
                  value:
                      _deathDate == null ? null : _dateFmt.format(_deathDate!),
                  onTap: () => _pickDate(isBirth: false),
                ),
              ],
              const SizedBox(height: 16),
              _label('Catatan'),
              TextFormField(
                controller: _notes,
                maxLines: 3,
                decoration: const InputDecoration(
                    hintText: 'cth. Leluhur pendiri keluarga.'),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.page))
                    : const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t,
            style: AppTheme.sans(
                size: 13, weight: FontWeight.w600, color: AppColors.inkSoft)),
      );

  Widget _photoPicker() {
    final accent = AppColors.genderColor(_gender == Gender.male);
    return Stack(
      children: [
        Container(
          height: 104,
          width: 104,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent.withValues(alpha: 0.12),
            border: Border.all(color: accent.withValues(alpha: 0.5), width: 2),
            image: _pickedPhoto != null
                ? DecorationImage(
                    image: MemoryImage(_pickedPhoto!), fit: BoxFit.cover)
                : (widget.existing?.photoUrl != null
                    ? DecorationImage(
                        image: NetworkImage(widget.existing!.photoUrl!),
                        fit: BoxFit.cover)
                    : null),
          ),
          alignment: Alignment.center,
          child: (_pickedPhoto == null && widget.existing?.photoUrl == null)
              ? Icon(Icons.add_a_photo_outlined, color: accent, size: 30)
              : null,
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: _pickPhoto,
            child: Container(
              height: 34,
              width: 34,
              decoration: BoxDecoration(
                color: AppColors.brand,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.page, width: 2),
              ),
              child: const Icon(Icons.edit_rounded,
                  size: 16, color: AppColors.page),
            ),
          ),
        ),
      ],
    );
  }
}

/// Toggle dua-pilihan untuk jenis kelamin.
class _GenderToggle extends StatelessWidget {
  final Gender value;
  final ValueChanged<Gender> onChanged;
  const _GenderToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _option(Gender.male, Icons.male_rounded, AppColors.male),
        const SizedBox(width: 12),
        _option(Gender.female, Icons.female_rounded, AppColors.female),
      ],
    );
  }

  Widget _option(Gender g, IconData icon, Color accent) {
    final selected = value == g;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(g),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: 0.14)
                : AppColors.surfaceSunk,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? accent : AppColors.border,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 20,
                  color: selected ? accent : AppColors.inkFaint),
              const SizedBox(width: 8),
              Text(g.label,
                  style: AppTheme.sans(
                      size: 14,
                      weight: FontWeight.w600,
                      color: selected ? AppColors.ink : AppColors.inkSoft)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String? value;
  final VoidCallback onTap;
  const _DateTile({this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceSunk,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Text(value ?? 'Pilih tanggal',
                style: AppTheme.sans(
                    size: 15,
                    color: value == null ? AppColors.inkFaint : AppColors.ink)),
            const Spacer(),
            const Icon(Icons.calendar_today_rounded,
                size: 18, color: AppColors.inkSoft),
          ],
        ),
      ),
    );
  }
}
