import 'dart:io';

import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app_database.dart';

/// Mengelola file save: satu slot = satu file SQLite (`save_<slot>.sqlite`).
abstract final class SaveStorage {
  static const int maxSlots = 3;

  static Future<Directory> _savesDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'futbol_saves'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static Future<File> slotFile(int slot) async {
    final dir = await _savesDir();
    return File(p.join(dir.path, 'save_$slot.sqlite'));
  }

  /// Membuka database untuk slot tertentu (file dibuat bila belum ada).
  static Future<AppDatabase> open(int slot) async {
    final file = await slotFile(slot);
    return AppDatabase(NativeDatabase.createInBackground(file));
  }

  /// Slot yang sudah berisi file save.
  static Future<List<int>> existingSlots() async {
    final result = <int>[];
    for (var slot = 1; slot <= maxSlots; slot++) {
      if (await (await slotFile(slot)).exists()) result.add(slot);
    }
    return result;
  }

  /// Slot kosong pertama, atau null bila semua terisi.
  static Future<int?> firstFreeSlot() async {
    final used = await existingSlots();
    for (var slot = 1; slot <= maxSlots; slot++) {
      if (!used.contains(slot)) return slot;
    }
    return null;
  }

  /// Slot dengan waktu modifikasi terbaru ("Lanjutkan").
  static Future<int?> latestSlot() async {
    int? best;
    DateTime? bestTime;
    for (final slot in await existingSlots()) {
      final stat = await (await slotFile(slot)).stat();
      if (bestTime == null || stat.modified.isAfter(bestTime)) {
        best = slot;
        bestTime = stat.modified;
      }
    }
    return best;
  }

  static Future<void> delete(int slot) async {
    final file = await slotFile(slot);
    if (await file.exists()) await file.delete();
  }
}
