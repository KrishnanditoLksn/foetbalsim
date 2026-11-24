import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app_database.dart';

/// Mengelola file save: satu slot = satu file SQLite (`save_<slot>.sqlite`).
abstract final class SaveStorage {
  static const int maxSlots = 5;

  /// Direktori save pengganti untuk unit test (mis. direktori sementara).
  @visibleForTesting
  static Future<Directory> Function()? savesDirOverride;

  static Future<Directory> _savesDir() async {
    final override = savesDirOverride;
    if (override != null) return override();
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

  /// Menghapus file save beserta file pendamping SQLite (`-wal`, `-shm`,
  /// `-journal`), agar slot benar-benar bersih saat dipakai ulang.
  /// Database slot ini harus sudah ditutup (lihat `deleteSave`).
  static Future<void> delete(int slot) async {
    final file = await slotFile(slot);
    final candidates = [
      file,
      File('${file.path}-wal'),
      File('${file.path}-shm'),
      File('${file.path}-journal'),
    ];
    for (final f in candidates) {
      if (await f.exists()) await f.delete();
    }
  }
}
