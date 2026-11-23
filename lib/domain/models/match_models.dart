import '../enums/tactics.dart';

/// Susunan taktik sebuah klub yang disimpan di save (tabel ClubTactics).
/// [starterIds] berurutan sesuai slot formasi; [subIds] adalah bangku cadangan.
class ClubTactic {
  const ClubTactic({
    required this.clubId,
    required this.formation,
    required this.mentality,
    required this.starterIds,
    required this.subIds,
  });

  final String clubId;
  final Formation formation;
  final Mentality mentality;
  final List<int> starterIds;
  final List<int> subIds;

  ClubTactic copyWith({
    Formation? formation,
    Mentality? mentality,
    List<int>? starterIds,
    List<int>? subIds,
  }) => ClubTactic(
    clubId: clubId,
    formation: formation ?? this.formation,
    mentality: mentality ?? this.mentality,
    starterIds: starterIds ?? this.starterIds,
    subIds: subIds ?? this.subIds,
  );
}

enum MatchEventType {
  kickOff,
  halfTime,
  fullTime,
  chance,
  shotOff,
  save,
  goal,
  foul,
  yellow,
  red,
  substitution,
  mentality,
}

/// Satu baris komentar laga.
class MatchEvent {
  const MatchEvent({
    required this.minute,
    required this.type,
    required this.text,
    this.isHome,
    this.playerId,
    this.assistId,
  });

  final int minute;
  final MatchEventType type;
  final String text;
  final bool? isHome; // null untuk peristiwa netral (kick-off, dll.)
  final int? playerId;
  final int? assistId;
}

/// Posisi satu pemain di lapangan. Koordinat ternormalisasi 0–1:
/// [x] sepanjang lapangan (gawang kiri 0 → gawang kanan 1),
/// [y] selebar lapangan (0 atas → 1 bawah).
class PlayerDot {
  const PlayerDot({
    required this.index,
    required this.playerId,
    required this.isHome,
    required this.shirt,
    required this.x,
    required this.y,
  });

  final int index; // 0–10 tim kandang, 11–21 tim tandang
  final int playerId;
  final bool isHome;
  final int shirt;
  final double x;
  final double y;
}

/// Hasil satu menit simulasi: posisi awal & akhir untuk animasi, bola, dan
/// peristiwa yang terjadi di menit tersebut.
class MinuteFrame {
  const MinuteFrame({
    required this.minute,
    required this.from,
    required this.to,
    required this.ballFromX,
    required this.ballFromY,
    required this.ballToX,
    required this.ballToY,
    required this.carrierIndex,
    required this.events,
  });

  final int minute;
  final List<PlayerDot> from;
  final List<PlayerDot> to;
  final double ballFromX;
  final double ballFromY;
  final double ballToX;
  final double ballToY;
  final int carrierIndex; // indeks pemain yang menguasai bola di akhir menit
  final List<MatchEvent> events;
}

class TeamMatchStats {
  const TeamMatchStats({
    this.possessionActions = 0,
    this.shots = 0,
    this.onTarget = 0,
    this.saves = 0,
    this.fouls = 0,
    this.yellow = 0,
    this.red = 0,
  });

  final int possessionActions;
  final int shots;
  final int onTarget;
  final int saves;
  final int fouls;
  final int yellow;
  final int red;
}

class MatchStats {
  const MatchStats({required this.home, required this.away});

  final TeamMatchStats home;
  final TeamMatchStats away;

  /// Penguasaan bola (%) berdasarkan jumlah aksi yang dimulai tiap tim.
  int get homePossession {
    final total = home.possessionActions + away.possessionActions;
    if (total == 0) return 50;
    return (home.possessionActions * 100 / total).round();
  }

  int get awayPossession => 100 - homePossession;
}

/// Ringkasan final laga 2D yang siap disimpan ke database.
class MatchResultData {
  const MatchResultData({
    required this.fixtureId,
    required this.homeClubId,
    required this.awayClubId,
    required this.homeGoals,
    required this.awayGoals,
    required this.events,
    required this.stats,
    required this.minutesPlayed,
    required this.homeScorerNames,
    required this.awayScorerNames,
  });

  final int fixtureId;
  final String homeClubId;
  final String awayClubId;
  final int homeGoals;
  final int awayGoals;
  final List<MatchEvent> events;
  final MatchStats stats;
  final Map<int, int> minutesPlayed; // playerId → menit bermain
  final List<String> homeScorerNames;
  final List<String> awayScorerNames;
}
