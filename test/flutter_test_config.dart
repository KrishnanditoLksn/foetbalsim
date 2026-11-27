import 'dart:async';

import 'package:futbol/l10n/l10n.dart';

/// Dijalankan Flutter sebelum setiap file test di `test/`. Test lama
/// mencocokkan teks berbahasa Indonesia, jadi bahasa default test = id.
/// Test terjemahan sendiri mengganti `L10n.current` sesuai kebutuhan.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  L10n.current = AppLanguage.id;
  await testMain();
}
