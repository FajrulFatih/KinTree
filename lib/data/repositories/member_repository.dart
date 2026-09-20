import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';
import '../models/member_model.dart';

/// CRUD anggota + stream realtime + upload foto (dengan kompresi).
class MemberRepository {
  final SupabaseClient _client;
  MemberRepository(this._client);

  /// Stream realtime semua anggota dalam satu grup.
  Stream<List<MemberModel>> watchMembers(String familyId) => _client
      .from('members')
      .stream(primaryKey: ['id'])
      .eq('family_id', familyId)
      .map((rows) => rows.map(MemberModel.fromMap).toList());

  Future<MemberModel> upsert(MemberModel member, {String? id}) async {
    final data = member.toInsertMap();
    final Map<String, dynamic> row;
    if (id == null) {
      row = await _client.from('members').insert(data).select().single();
    } else {
      row =
          await _client.from('members').update(data).eq('id', id).select().single();
    }
    return MemberModel.fromMap(row);
  }

  Future<void> delete(String id) =>
      _client.from('members').delete().eq('id', id);

  /// Kompres (maks 400px, JPEG 75%) lalu unggah ke Storage; kembalikan URL publik.
  Future<String> uploadPhoto({
    required String familyId,
    required String memberId,
    required Uint8List bytes,
  }) async {
    final compressed = await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: 400,
      minHeight: 400,
      quality: 75,
      format: CompressFormat.jpeg,
    );
    final path = '$familyId/$memberId.jpg';
    final storage = _client.storage.from(SupabaseConfig.memberPhotosBucket);
    await storage.uploadBinary(
      path,
      compressed,
      fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
    );
    // Tambah cache-buster agar foto baru langsung tampil.
    return '${storage.getPublicUrl(path)}?v=${DateTime.now().millisecondsSinceEpoch}';
  }
}
