import 'package:flutter/material.dart';

/// Palet "Warm Heritage" (desain v2). Nuansa kertas tua / arsip keluarga:
/// krem hangat, tinta cokelat, aksen hijau hutan, dan warna node teredam.
class AppColors {
  // Permukaan & latar
  static const Color page = Color(0xFFFCF8F0); // latar utama
  static const Color surface = Color(0xFFFCF8F0); // kartu
  static const Color surfaceAlt = Color(0xFFF8F4EA); // kartu alternatif
  static const Color surfaceSunk = Color(0xFFF1E9D8); // field/inset

  // Tinta (teks)
  static const Color ink = Color(0xFF2B2117); // utama
  static const Color inkSoft = Color(0xFF6F6552); // sekunder
  static const Color inkFaint = Color(0xFF9A8C6F); // tersier/hint

  // Garis
  static const Color border = Color(0xFFE4DBC9);
  static const Color borderStrong = Color(0xFFD8CFBD);

  // Brand & aksen
  static const Color brand = Color(0xFF3C6B53); // hijau hutan
  static const Color brandDark = Color(0xFF2F5742);
  static const Color heritage = Color(0xFFB07B3E); // ochre (akar/sesepuh)
  static const Color male = Color(0xFF5E7E8C); // biru-abu
  static const Color female = Color(0xFFA8746F); // mauve
  static const Color danger = Color(0xFFBB4A3F); // terracotta

  // Aksen lembut (latar chip/tag)
  static const Color goldPale = Color(0xFFFBE8B8);

  static Color genderColor(bool isMale) => isMale ? male : female;
}
