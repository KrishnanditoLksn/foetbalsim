import 'common.dart';
import 'engine.dart';
import 'screens_a.dart';
import 'screens_b.dart';
import 'transfer.dart';
import 'tr_entry.dart';

export 'tr_entry.dart';

/// Semua kamus per bagian, digabung. Kunci ganda dicek oleh unit test
/// `test/l10n/strings_test.dart`.
const List<Map<String, Tr>> stringTables = [
  commonStrings,
  screensAStrings,
  screensBStrings,
  transferStrings,
  engineStrings,
];

final Map<String, Tr> allStrings = {for (final t in stringTables) ...t};
