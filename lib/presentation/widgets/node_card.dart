import 'package:flutter/material.dart';

import '../../core/constants/enums.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/member_model.dart';

/// Node pohon (desain v2): avatar lingkaran solid + inisial putih, nama serif,
/// tahun. Default tanpa kartu (mengambang di pita generasi); saat terpilih
/// muncul kartu + border hijau. Yang wafat: avatar teredam + tag "Alm.".
class NodeCard extends StatelessWidget {
  final MemberModel member;
  final bool highlighted;
  final VoidCallback? onTap;

  const NodeCard({
    super.key,
    required this.member,
    this.highlighted = false,
    this.onTap,
  });

  String get _initials {
    final name = member.fullName.trim();
    if (name.isEmpty) return '?';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  String get _years {
    final b = member.birthDate?.year;
    if (!member.isAlive) {
      final d = member.deathDate?.year;
      if (b != null || d != null) return '${b ?? '?'}–${d ?? ''}';
      return '';
    }
    return b != null ? 'b. $b' : '';
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.genderColor(member.gender == Gender.male);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: highlighted ? AppColors.brand : AppColors.border,
              width: highlighted ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0x142B2117),
                blurRadius: highlighted ? 12 : 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Avatar(
                member: member,
                accent: accent,
                initials: _initials,
              ),
              const SizedBox(height: 8),
              Text(
                member.fullName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTheme.serif(
                  size: 14,
                  weight: FontWeight.w600,
                  color: member.isAlive ? AppColors.ink : AppColors.inkSoft,
                  height: 1.1,
                ),
              ),
              if (_years.isNotEmpty) ...[
                const SizedBox(height: 1),
                Text(_years,
                    style:
                        AppTheme.sans(size: 11, color: AppColors.inkFaint)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final MemberModel member;
  final Color accent;
  final String initials;

  const _Avatar({
    required this.member,
    required this.accent,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    final deceased = !member.isAlive;

    Widget avatar = Container(
      height: 52,
      width: 52,
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
          ? Text(initials,
              style: AppTheme.sans(
                  size: 19,
                  weight: FontWeight.w600,
                  color: AppColors.page))
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
        child: Opacity(opacity: 0.9, child: avatar),
      );
      return Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            bottom: -3,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('Alm.',
                    style: AppTheme.sans(
                        size: 9,
                        weight: FontWeight.w600,
                        color: AppColors.page)),
              ),
            ),
          ),
        ],
      );
    }

    return avatar;
  }
}
