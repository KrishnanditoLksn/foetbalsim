import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/app_database.dart';
import '../l10n/l10n.dart';
import '../data/repositories/club_repository.dart';
import '../data/repositories/fixture_repository.dart';
import '../data/repositories/game_state_repository.dart';
import '../data/repositories/player_repository.dart';
import '../data/repositories/tactics_repository.dart';
import '../data/repositories/transfer_repository.dart';
import '../data/repositories/world_repository.dart';
import '../data/services/game_engine.dart';
import '../data/services/transfer_service.dart';
import '../domain/generators/seed_catalog.dart';
import '../domain/match/lineup_builder.dart';
import '../domain/models/game_models.dart';
import '../domain/models/match_models.dart';
import '../domain/models/season_models.dart';
import '../domain/models/transfer_models.dart';
import '../domain/season/league_table.dart';

/// Katalog liga & klub dari seed JSON. Tidak membutuhkan database,
/// sehingga aman dipakai sebelum karier dibuat.
final seedCatalogProvider = FutureProvider<SeedCatalog>((ref) async {
  final json = await WorldRepository.loadSeedJson();
  return SeedCatalog.parse(json);
});

/// Database save yang sedang aktif (null = belum ada save dibuka).
final currentDatabaseProvider = StateProvider<AppDatabase?>((ref) => null);

/// Slot save yang sedang aktif (1–5, lihat `SaveStorage.maxSlots`).
final activeSaveSlotProvider = StateProvider<int?>((ref) => null);

/// Ringkasan LANJUTKAN terakhir (kartu "Hari Ini" di dashboard).
final lastDayReportProvider = StateProvider<DayReport?>((ref) => null);

/// Klub yang dilatih (null bila belum ada save aktif). Dipakai tema:
/// aksen aplikasi mengikuti warna klub.
final ourClubProvider = Provider<Club?>((ref) {
  if (ref.watch(currentDatabaseProvider) == null) return null;
  final clubId = ref.watch(gameStateProvider).valueOrNull?.clubId;
  if (clubId == null) return null;
  return ref.watch(clubByIdProvider(clubId)).valueOrNull;
});

/// Tab aktif di shell utama (0 Beranda, 1 Skuad, 2 Jadwal, 3 Transfer,
/// 4 Inbox). Auto-dispose: kembali ke Beranda setiap shell dibuka ulang.
final shellTabProvider = StateProvider.autoDispose<int>((ref) => 0);

/// Naik setiap kali data permainan berubah. Provider yang membaca data
/// permainan menonton angka ini agar otomatis dihitung ulang.
final worldVersionProvider = StateProvider<int>((ref) => 0);

/// Database save aktif. Melempar error jika belum ada save yang dibuka.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = ref.watch(currentDatabaseProvider);
  if (db == null) {
    throw StateError(tr('err.noActiveSave'));
  }
  return db;
});

final clubRepositoryProvider = Provider<ClubRepository>(
  (ref) => ClubRepository(ref.watch(databaseProvider)),
);

final playerRepositoryProvider = Provider<PlayerRepository>(
  (ref) => PlayerRepository(ref.watch(databaseProvider)),
);

final gameStateRepositoryProvider = Provider<GameStateRepository>(
  (ref) => GameStateRepository(ref.watch(databaseProvider)),
);

final fixtureRepositoryProvider = Provider<FixtureRepository>(
  (ref) => FixtureRepository(ref.watch(databaseProvider)),
);

final gameEngineProvider = Provider<GameEngine>(
  (ref) => GameEngine(ref.watch(databaseProvider)),
);

final tacticsRepositoryProvider = Provider<TacticsRepository>(
  (ref) => TacticsRepository(ref.watch(databaseProvider)),
);

final transferRepositoryProvider = Provider<TransferRepository>(
  (ref) => TransferRepository(ref.watch(databaseProvider)),
);

/// Taktik tersimpan tim kita (null bila belum pernah diatur).
final clubTacticProvider = FutureProvider<ClubTactic?>((ref) async {
  ref.watch(worldVersionProvider);
  final state = await ref.watch(gameStateProvider.future);
  final clubId = state?.clubId;
  if (clubId == null) return null;
  return ref.watch(tacticsRepositoryProvider).load(clubId);
});

/// Skuad tim kita yang sudah disusun sesuai taktik (starter & bangku).
final lineupProvider =
    FutureProvider<({List<Player> starters, List<Player> bench})>((ref) async {
      ref.watch(worldVersionProvider);
      final state = await ref.watch(gameStateProvider.future);
      final clubId = state?.clubId;
      if (clubId == null) return (starters: <Player>[], bench: <Player>[]);
      final squad = await ref.watch(squadProvider(clubId).future);
      final saved = await ref.watch(clubTacticProvider.future);
      return LineupBuilder.resolve(squad, saved);
    });

/// Semua pemain di database untuk layar pencarian.
final playerSearchRowsProvider = FutureProvider<List<PlayerSearchRow>>((ref) {
  ref.watch(worldVersionProvider);
  return ref.watch(playerRepositoryProvider).allForSearch();
});

/// Tawaran yang melibatkan klub kita (keluar & masuk).
final clubOffersProvider = FutureProvider<List<TransferOffer>>((ref) async {
  ref.watch(worldVersionProvider);
  final state = await ref.watch(gameStateProvider.future);
  final clubId = state?.clubId;
  if (clubId == null) return const [];
  return ref.watch(transferRepositoryProvider).offersFor(clubId);
});

/// Sesi Ruang Negosiasi yang masih berjalan, per id tawaran.
final activeNegotiationsProvider =
    FutureProvider<Map<int, NegotiationSessionRow>>((ref) async {
      ref.watch(worldVersionProvider);
      final rows = await ref.watch(transferRepositoryProvider).activeSessions();
      return {for (final r in rows) r.offerId: r};
    });

final transferHistoryProvider = FutureProvider<List<TransferRecord>>((ref) {
  ref.watch(worldVersionProvider);
  return ref.watch(transferRepositoryProvider).history();
});

final shortlistProvider = FutureProvider<Set<int>>((ref) {
  ref.watch(worldVersionProvider);
  return ref.watch(transferRepositoryProvider).shortlistIds();
});

/// Harga minta untuk klub kita dan apakah pemain bisa ditawar sekarang.
final transferQuoteProvider = FutureProvider.family<TransferQuote, int>((
  ref,
  playerId,
) {
  ref.watch(worldVersionProvider);
  return ref.watch(gameEngineProvider).transferQuote(playerId);
});

/// Klub yang berminat pada seorang pemain (README_FASE3 B.10.6).
final playerInterestsProvider =
    FutureProvider.family<List<PlayerInterest>, int>((ref, playerId) {
      ref.watch(worldVersionProvider);
      return ref.watch(gameEngineProvider).interestsFor(playerId);
    });

/// Berita bursa terbaru (rumor, transfer, tawaran AI, deadline).
final transferNewsProvider = FutureProvider<List<TransferNewsItem>>((ref) {
  ref.watch(worldVersionProvider);
  return ref.watch(gameEngineProvider).transferNews();
});
final clubByIdProvider = FutureProvider.family<Club?, String>((ref, clubId) {
  ref.watch(worldVersionProvider);
  return ref.watch(clubRepositoryProvider).clubById(clubId);
});

/// Semua klub dalam satu peta (id → klub), untuk menampilkan nama lawan.
final allClubsMapProvider = FutureProvider<Map<String, Club>>((ref) async {
  ref.watch(worldVersionProvider);
  final repo = ref.watch(clubRepositoryProvider);
  final leagues = await repo.leagues();
  final map = <String, Club>{};
  for (final league in leagues) {
    for (final club in await repo.clubsByLeague(league.id)) {
      map[club.id] = club;
    }
  }
  return map;
});

final squadProvider = FutureProvider.family<List<Player>, String>((
  ref,
  clubId,
) {
  ref.watch(worldVersionProvider);
  return ref.watch(playerRepositoryProvider).squad(clubId);
});

final playerDetailProvider = FutureProvider.family<PlayerDetail?, int>((
  ref,
  playerId,
) {
  ref.watch(worldVersionProvider);
  return ref.watch(playerRepositoryProvider).detail(playerId);
});

final gameStateProvider = FutureProvider<GameState?>((ref) {
  ref.watch(worldVersionProvider);
  return ref.watch(gameStateRepositoryProvider).load();
});

final gameStatusProvider = FutureProvider<GameStatus>((ref) {
  ref.watch(worldVersionProvider);
  return ref.watch(gameEngineProvider).status();
});

final inboxProvider = FutureProvider<List<InboxMessage>>((ref) {
  ref.watch(worldVersionProvider);
  return ref.watch(gameEngineProvider).inbox();
});

/// Jadwal satu liga (kedua liga dipakai di layar jadwal).
final leagueFixturesProvider = FutureProvider.family<List<Fixture>, String>((
  ref,
  leagueId,
) {
  ref.watch(worldVersionProvider);
  return ref.watch(fixtureRepositoryProvider).forLeague(leagueId);
});

/// Jadwal tim kita (kandang & tandang).
final clubFixturesProvider = FutureProvider.family<List<Fixture>, String>((
  ref,
  clubId,
) {
  ref.watch(worldVersionProvider);
  return ref.watch(fixtureRepositoryProvider).forClub(clubId);
});

/// Klasemen satu liga, dihitung dari hasil laga.
final leagueTableProvider = FutureProvider.family<List<LeagueTableRow>, String>(
  (ref, leagueId) async {
    final fixtures = await ref.watch(leagueFixturesProvider(leagueId).future);
    final clubs = await ref
        .watch(clubRepositoryProvider)
        .clubsByLeague(leagueId);
    return LeagueTable.compute(
      clubIds: clubs.map((c) => c.id).toList(),
      fixtures: fixtures,
    );
  },
);

/// Daftar liga dari database (dipakai setelah karier dibuat).
final leaguesProvider = FutureProvider<List<League>>((ref) {
  ref.watch(worldVersionProvider);
  return ref.watch(clubRepositoryProvider).leagues();
});
