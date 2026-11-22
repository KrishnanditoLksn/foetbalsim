import '../database/save_storage.dart';
import 'club_repository.dart';
import 'game_state_repository.dart';

/// Ringkasan satu slot save untuk daftar "Muat Karier".
class SaveSummary {
  const SaveSummary({
    required this.slot,
    required this.managerName,
    required this.clubName,
    required this.currentDate,
    required this.modified,
  });

  final int slot;
  final String managerName;
  final String clubName;
  final DateTime currentDate;
  final DateTime modified; // waktu terakhir file save ditulis
}

abstract final class SaveSummaryRepository {
  /// Membaca ringkasan tanpa menjadikan save itu aktif.
  /// Mengembalikan null bila slot tidak punya data karier yang valid.
  static Future<SaveSummary?> read(int slot) async {
    final db = await SaveStorage.open(slot);
    try {
      final state = await GameStateRepository(db).load();
      if (state == null) return null;

      final clubId = state.clubId;
      final club =
          clubId == null ? null : await ClubRepository(db).clubById(clubId);

      final stat = (await SaveStorage.slotFile(slot)).statSync();
      return SaveSummary(
        slot: slot,
        managerName: state.managerName,
        clubName: club?.name ?? '-',
        currentDate: state.currentDate,
        modified: stat.modified,
      );
    } finally {
      await db.close();
    }
  }
}
