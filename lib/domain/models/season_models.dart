import '../enums/inbox.dart';

class Fixture {
  const Fixture({
    required this.id,
    required this.leagueId,
    required this.round,
    required this.date,
    required this.homeClubId,
    required this.awayClubId,
    this.homeGoals,
    this.awayGoals,
  });

  final int id;
  final String leagueId;
  final int round;
  final DateTime date; // UTC, tengah malam
  final String homeClubId;
  final String awayClubId;
  final int? homeGoals;
  final int? awayGoals;

  bool get played => homeGoals != null && awayGoals != null;

  bool involves(String clubId) => homeClubId == clubId || awayClubId == clubId;
}

class InboxMessage {
  const InboxMessage({
    required this.id,
    required this.date,
    required this.category,
    required this.title,
    required this.body,
    required this.isRead,
    required this.actionType,
    required this.payload,
    required this.resolved,
    required this.choice,
  });

  final int id; // 0 saat belum disimpan
  final DateTime date;
  final InboxCategory category;
  final String title;
  final String body;
  final bool isRead;
  final InboxActionType actionType;
  final String? payload; // mis. "player:12" atau "target:5"
  final bool resolved;
  final String? choice;

  bool get needsAction => actionType != InboxActionType.none && !resolved;
}

class LeagueTableRow {
  const LeagueTableRow({
    required this.clubId,
    required this.played,
    required this.won,
    required this.drawn,
    required this.lost,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.points,
    required this.form,
  });

  final String clubId;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int goalsFor;
  final int goalsAgainst;
  final int points;
  final List<String> form; // maks. 5 terakhir: 'W', 'D', 'L'

  int get goalDiff => goalsFor - goalsAgainst;
}
