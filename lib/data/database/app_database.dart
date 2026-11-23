import 'package:drift/drift.dart';

import '../../domain/enums/inbox.dart';
import '../../domain/enums/position.dart';
import '../../domain/enums/squad_status.dart';
import '../../domain/enums/tactics.dart';
import '../../domain/enums/transfer.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// Satu instance = satu file save SQLite.
///
/// v1: data dunia (Fase 1).
/// v2: Fixtures + InboxMessages (Fase 2). Save v1 dimigrasi otomatis.
/// v3: ClubTactics, TransferOffers, TransferHistory, Shortlist, dan kolom
///     Players.isTransferListed (Fase 3). Save v1/v2 dimigrasi otomatis.
@DriftDatabase(
  tables: [
    Nations,
    Leagues,
    Clubs,
    Players,
    Contracts,
    GameStates,
    Fixtures,
    InboxMessages,
    ClubTactics,
    TransferOffers,
    TransferHistory,
    Shortlist,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(fixtures);
        await m.createTable(inboxMessages);
      }
      if (from < 3) {
        await m.addColumn(players, players.isTransferListed);
        await m.createTable(clubTactics);
        await m.createTable(transferOffers);
        await m.createTable(transferHistory);
        await m.createTable(shortlist);
      }
    },
  );
}
