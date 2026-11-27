import '../models/transfer_models.dart';

/// Penyaringan dan pengurutan hasil pencarian pemain (murni, tanpa database).
abstract final class PlayerSearch {
  static List<PlayerSearchRow> apply(
    List<PlayerSearchRow> rows,
    PlayerSearchFilter f, {
    required DateTime now,
  }) {
    final q = f.query.trim().toLowerCase();
    final sixMonths = DateTime.utc(now.year, now.month + 6, now.day);

    final filtered =
        rows.where((r) {
          final p = r.player;
          if (q.isNotEmpty && !p.fullName.toLowerCase().contains(q))
            return false;
          if (f.group != null && p.position.group != f.group) return false;
          if (f.position != null && p.position != f.position) return false;
          if (f.ageMin != null && p.age < f.ageMin!) return false;
          if (f.ageMax != null && p.age > f.ageMax!) return false;
          if (f.caMin != null && p.currentAbility < f.caMin!) return false;
          if (f.caMax != null && p.currentAbility > f.caMax!) return false;
          if (f.maxMarketValue != null && p.marketValue > f.maxMarketValue!) {
            return false;
          }
          if (f.leagueId != null && r.leagueId != f.leagueId) return false;
          if (f.clubId != null && p.clubId != f.clubId) return false;
          switch (f.status) {
            case PlayerSearchStatus.all:
              break;
            case PlayerSearchStatus.forSale:
              if (!p.isTransferListed) return false;
            case PlayerSearchStatus.expiringSoon:
              final end = r.contract?.endDate;
              if (end == null || end.isAfter(sixMonths)) return false;
            case PlayerSearchStatus.freeAgent:
              if (r.contract != null) return false;
          }
          return true;
        }).toList();

    int cmp(PlayerSearchRow a, PlayerSearchRow b) => switch (f.sort) {
      PlayerSort.ca => a.player.currentAbility.compareTo(
        b.player.currentAbility,
      ),
      PlayerSort.pa => a.player.potentialAbility.compareTo(
        b.player.potentialAbility,
      ),
      PlayerSort.age => a.player.age.compareTo(b.player.age),
      PlayerSort.marketValue => a.player.marketValue.compareTo(
        b.player.marketValue,
      ),
      PlayerSort.wage => (a.contract?.wage ?? 0).compareTo(
        b.contract?.wage ?? 0,
      ),
      PlayerSort.name => a.player.fullName.compareTo(b.player.fullName),
    };

    filtered.sort((a, b) {
      final c = cmp(a, b);
      if (c != 0) return f.ascending ? c : -c;
      return a.player.id.compareTo(b.player.id);
    });
    return filtered;
  }
}
