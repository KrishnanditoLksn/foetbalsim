import '../../l10n/l10n.dart';
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
    this.installmentYears = 1,
    this.sellOnPct = 0,
    this.reason,
  });

  final int id;
  final int playerId;
  final String fromClubId;
  final String toClubId;
  final int fee; // €K
  final TransferOfferStatus status;
  final DateTime createdDate;
  final DateTime? responseDate;

  /// 1 = dibayar langsung; 2 atau 3 = dicicil per tahun.
  final int installmentYears;

  /// Bagian penjual dari penjualan berikutnya (0 atau 10–30%).
  final int sellOnPct;

  /// Alasan penolakan atau kegagalan (bila ada).
  final String? reason;

  /// Tawaran dari klub lain untuk pemain [ourClubId] (kita penjual).
  bool isIncomingFor(String ourClubId) => toClubId == ourClubId;

  /// Negosiasi masih berjalan (termasuk menunggu jawaban atas kontra).
  bool get isActive =>
      status == TransferOfferStatus.pending ||
      status == TransferOfferStatus.awaitingContract ||
      status == TransferOfferStatus.countered;
}

/// Satu berita bursa: rumor, transfer, tawaran AI, atau info deadline.
class TransferNewsItem {
  const TransferNewsItem({
    required this.date,
    required this.kind,
    required this.body,
  });

  final DateTime date;
  final String kind; // rumour / deal / offer / deadline
  final String body;
}

/// Klub yang berminat pada seorang pemain (README_FASE3 B.10.6).
class PlayerInterest {
  const PlayerInterest({
    required this.clubId,
    required this.clubName,
    required this.score,
    required this.levelLabel,
  });

  final String clubId;
  final String clubName;
  final int score;
  final String levelLabel;
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
  all,
  forSale,
  expiringSoon,
  freeAgent;

  String get label => tr('searchStatus.$name');
}

enum PlayerSort {
  ca,
  pa,
  age,
  marketValue,
  wage,
  name;

  // `this.` wajib: nilai enum `name` di atas menutupi getter `Enum.name`.
  String get label => tr('playerSort.${this.name}');
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
