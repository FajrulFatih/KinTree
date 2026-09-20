import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/family_model.dart';

/// Akses grup keluarga. Pembuatan & penggabungan dilakukan lewat RPC
/// (security definer) agar tidak terbentur RLS chicken-egg.
class FamilyRepository {
  final SupabaseClient _client;
  FamilyRepository(this._client);

  /// Daftar grup yang diikuti user saat ini (lewat join family_members).
  Future<List<FamilyModel>> myFamilies() async {
    final rows = await _client
        .from('families')
        .select()
        .order('created_at', ascending: false);
    return (rows as List)
        .map((e) => FamilyModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<FamilyModel> createFamily(String name) async {
    final res = await _client.rpc('create_family', params: {
      'p_name': name,
      'p_invite_code': _generateInviteCode(),
    });
    return FamilyModel.fromMap(_firstRow(res));
  }

  Future<FamilyModel> joinFamily(String inviteCode) async {
    final res = await _client.rpc('join_family', params: {
      'p_invite_code': inviteCode.trim().toUpperCase(),
    });
    return FamilyModel.fromMap(_firstRow(res));
  }

  /// RPC bisa mengembalikan satu objek atau list berisi satu objek.
  Map<String, dynamic> _firstRow(dynamic res) {
    if (res is List) return res.first as Map<String, dynamic>;
    return res as Map<String, dynamic>;
  }

  static String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = Random.secure();
    return List.generate(6, (_) => chars[rnd.nextInt(chars.length)]).join();
  }
}
