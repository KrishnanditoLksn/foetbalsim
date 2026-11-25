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
/// v4: bursa AI (profil, minat, berita, memori), musim (Seasons, arsip, gelar),
///     dan kolom baru pada Players, TransferOffers, GameStates, Fixtures.
/// v3: ClubTactics, TransferOffers, TransferHistory, Shortlist, dan kolom
///     Players.isTransferListed (Fase 3). Save v1/v2 dimigrasi otomatis.
/// v5: NegotiationSessions (Ruang Negosiasi).
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
    ClubAiProfiles,
    TransferInterests,
    TransferNews,
    MarketMemory,
    Seasons,
    SeasonArchive,
    Honours,
    NegotiationSessions,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // Tabel yang dibuat di sini memakai definisi terkini (sudah mencakup
      // kolom versi-versi berikutnya), sehingga kolom itu tidak ditambah lagi.
      if (from < 2) {
        await m.createTable(fixtures);
        await m.createTable(inboxMessages);
      }
      if (from < 3) {
        await m.createTable(clubTactics);
        await m.createTable(transferOffers);
        await m.createTable(transferHistory);
        await m.createTable(shortlist);
        await m.addColumn(players, players.isTransferListed);
      }
      if (from == 3) {
        await m.addColumn(transferOffers, transferOffers.installmentYears);
        await m.addColumn(transferOffers, transferOffers.sellOnPct);
        await m.addColumn(transferOffers, transferOffers.round);
        await m.addColumn(transferOffers, transferOffers.expiresDate);
        await m.addColumn(transferOffers, transferOffers.reason);
        await m.addColumn(transferOffers, transferOffers.kind);
      }
      if (from < 4) {
        await m.addColumn(players, players.lockedUntil);
        await m.addColumn(gameStates, gameStates.seasonStartYear);
        if (from >= 2) {
          await m.addColumn(fixtures, fixtures.seasonStartYear);
          await m.addColumn(fixtures, fixtures.stage);
          await m.addColumn(fixtures, fixtures.leg);
        }
        await m.createTable(clubAiProfiles);
        await m.createTable(transferInterests);
        await m.createTable(transferNews);
        await m.createTable(marketMemory);
        await m.createTable(seasons);
        await m.createTable(seasonArchive);
        await m.createTable(honours);
        // Save lama (bertanggal 2025) tetap musim 2025/26 sampai selesai.
        await customStatement(
          'UPDATE game_states SET season_start_year = 2025 WHERE "current_date" < 1782864000',
        );
        if (from >= 2) {
          await customStatement(
            'UPDATE fixtures SET season_start_year = 2025 WHERE date < 1782864000',
          );
        }
      }
      if (from < 5) {
        await m.createTable(negotiationSessions);
      }
    },
  );
}
