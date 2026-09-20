import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/family_model.dart';
import 'supabase_providers.dart';

/// Menyimpan grup keluarga yang sedang aktif dibuka.
class ActiveFamilyNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? familyId) => state = familyId;
}

final activeFamilyProvider =
    NotifierProvider<ActiveFamilyNotifier, String?>(ActiveFamilyNotifier.new);

/// Daftar grup yang diikuti user saat ini.
final myFamiliesProvider = FutureProvider<List<FamilyModel>>((ref) async {
  // Re-fetch saat status auth berubah.
  ref.watch(currentUserProvider);
  return ref.watch(familyRepositoryProvider).myFamilies();
});
