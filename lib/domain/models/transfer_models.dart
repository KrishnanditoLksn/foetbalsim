import '../enums/position.dart';
import '../enums/transfer.dart';
import 'game_models.dart';

/// Tawaran transfer. [fromClubId] = klub yang menawar,
/// [toClubId] = klub yang menerima tawaran (penjual).
class TransferOffer {
  const TransferOffer({
    required this.id,
    required this.playerId,
    required this.fromClubId,
    required this.toClubId,
    required this.fee,
    required this.status,
    required this.createdDate,
    required this.responseDate,
  });

  final int id;
  final int playerId;
  final String fromClubId;
  final String toClubId;
  final int fee; // €K
  final TransferOfferStatus status;
  final DateTime createdDate;
  final DateTime? responseDate;

  bool get isActive =>
      status == TransferOfferStatus.pending ||
      status == TransferOfferStatus.awaitingContract;
}

class TransferRecord {
  const TransferRecord({
    required this.id,
    required this.date,
    required this.playerId,
    required this.playerName,
    required this.fromClubId,
    required this.toClubId,
    required this.fee,
    required this.type,
  });

  final int id;
  final DateTime date;
  final int playerId;
  final String playerName;
  final String fromClubId;
  final String toClubId;
  final int fee; // €K
  final TransferType type;
}

enum PlayerSearchStatus {
  all('Semua'),
  forSale('Daftar Jual'),
  expiringSoon('Kontrak Habis ≤ 6 Bln'),
  freeAgent('Agen Bebas');

  const PlayerSearchStatus(this.label);
  final String label;
}

enum PlayerSort {
  ca('CA'),
  pa('PA'),
  age('Usia'),
  marketValue('Nilai Pasar'),
  wage('Gaji'),
  name('Nama');

  const PlayerSort(this.label);
  final String label;
}

/// Filter pencarian pemain. Nilai null = tidak dibatasi.
class PlayerSearchFilter {
  const PlayerSearchFilter({
    this.query = '',
    this.group,
    this.position,
    this.ageMin,
    this.ageMax,
    this.caMin,
    this.caMax,
    this.maxMarketValue,
    this.status = PlayerSearchStatus.all,
    this.leagueId,
    this.clubId,
    this.sort = PlayerSort.ca,
    this.ascending = false,
  });

  final String query;
  final PositionGroup? group;
  final Position? position;
  final int? ageMin;
  final int? ageMax;
  final int? caMin;
  final int? caMax;
  final int? maxMarketValue; // €K
  final PlayerSearchStatus status;
  final String? leagueId;
  final String? clubId;
  final PlayerSort sort;
  final bool ascending;

  PlayerSearchFilter copyWith({
    String? query,
    PositionGroup? group,
    Position? position,
    int? ageMin,
    int? ageMax,
    int? caMin,
    int? caMax,
    int? maxMarketValue,
    PlayerSearchStatus? status,
    String? leagueId,
    String? clubId,
    PlayerSort? sort,
    bool? ascending,
    bool clearGroup = false,
    bool clearPosition = false,
    bool clearAgeMin = false,
    bool clearAgeMax = false,
    bool clearCaMin = false,
    bool clearCaMax = false,
    bool clearLeague = false,
    bool clearClub = false,
    bool clearMaxValue = false,
  }) => PlayerSearchFilter(
    query: query ?? this.query,
    group: clearGroup ? null : (group ?? this.group),
    position: clearPosition ? null : (position ?? this.position),
    ageMin: clearAgeMin ? null : (ageMin ?? this.ageMin),
    ageMax: clearAgeMax ? null : (ageMax ?? this.ageMax),
    caMin: clearCaMin ? null : (caMin ?? this.caMin),
    caMax: clearCaMax ? null : (caMax ?? this.caMax),
    maxMarketValue:
        clearMaxValue ? null : (maxMarketValue ?? this.maxMarketValue),
    status: status ?? this.status,
    leagueId: clearLeague ? null : (leagueId ?? this.leagueId),
    clubId: clearClub ? null : (clubId ?? this.clubId),
    sort: sort ?? this.sort,
    ascending: ascending ?? this.ascending,
  );
}

/// Baris hasil pencarian: pemain plus info klub, liga, dan kontraknya.
class PlayerSearchRow {
  const PlayerSearchRow({
    required this.player,
    required this.contract,
    required this.clubName,
    required this.leagueId,
    required this.isForSale,
  });

  final Player player;
  final Contract? contract;
  final String clubName;
  final String? leagueId;
  final bool isForSale;
}
