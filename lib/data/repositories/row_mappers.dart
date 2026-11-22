import 'package:drift/drift.dart';

import '../../domain/enums/attribute.dart';
import '../../domain/models/game_models.dart';
import '../../domain/models/player_attributes.dart';
import '../database/app_database.dart';

/// Konversi antara baris Drift dan model domain.
abstract final class RowMappers {
  static Nation nation(NationRow r) =>
      Nation(id: r.id, name: r.name, code: r.code);

  static League league(LeagueRow r) => League(
    id: r.id,
    nationId: r.nationId,
    name: r.name,
    tier: r.tier,
    jumlahTim: r.jumlahTim,
    slotPromosi: r.slotPromosi,
    slotDegradasi: r.slotDegradasi,
    slotPlayoff: r.slotPlayoff,
  );

  static Club club(ClubRow r) => Club(
    id: r.id,
    leagueId: r.leagueId,
    name: r.name,
    shortName: r.shortName,
    primaryColor: r.primaryColor,
    secondaryColor: r.secondaryColor,
    reputation: r.reputation,
    stadiumName: r.stadiumName,
    capacity: r.capacity,
    balance: r.balance,
    transferBudget: r.transferBudget,
    wageBudget: r.wageBudget,
  );

  static Player player(PlayerRow r) => Player(
    id: r.id,
    clubId: r.clubId,
    firstName: r.firstName,
    lastName: r.lastName,
    age: r.age,
    nationality: r.nationality,
    position: r.position,
    attributes: PlayerAttributes({
      Attribute.finishing: r.finishing,
      Attribute.passing: r.passing,
      Attribute.dribbling: r.dribbling,
      Attribute.firstTouch: r.firstTouch,
      Attribute.crossing: r.crossing,
      Attribute.tackling: r.tackling,
      Attribute.heading: r.heading,
      Attribute.technique: r.technique,
      Attribute.decisions: r.decisions,
      Attribute.positioning: r.positioning,
      Attribute.vision: r.vision,
      Attribute.composure: r.composure,
      Attribute.workRate: r.workRate,
      Attribute.aggression: r.aggression,
      Attribute.pace: r.pace,
      Attribute.acceleration: r.acceleration,
      Attribute.stamina: r.stamina,
      Attribute.strength: r.strength,
      Attribute.agility: r.agility,
      Attribute.handling: r.handling,
      Attribute.reflexes: r.reflexes,
      Attribute.oneOnOnes: r.oneOnOnes,
      Attribute.aerialReach: r.aerialReach,
    }),
    potentialAbility: r.potentialAbility,
    currentAbility: r.currentAbility,
    condition: r.condition,
    morale: r.morale,
    marketValue: r.marketValue,
  );

  static Contract contract(ContractRow r) => Contract(
    playerId: r.playerId,
    clubId: r.clubId,
    wage: r.wage,
    endDate: r.endDate.toUtc(), // Drift mengembalikan waktu lokal
    squadStatus: r.squadStatus,
  );

  static GameState gameState(GameStateRow r) => GameState(
    currentDate: r.currentDate.toUtc(),
    managerName: r.managerName,
    clubId: r.clubId,
    seed: r.seed,
  );

  static PlayersCompanion playerCompanion(Player p) {
    final a = p.attributes;
    return PlayersCompanion.insert(
      id: Value(p.id),
      clubId: p.clubId,
      firstName: p.firstName,
      lastName: p.lastName,
      age: p.age,
      nationality: p.nationality,
      position: p.position,
      finishing: a[Attribute.finishing],
      passing: a[Attribute.passing],
      dribbling: a[Attribute.dribbling],
      firstTouch: a[Attribute.firstTouch],
      crossing: a[Attribute.crossing],
      tackling: a[Attribute.tackling],
      heading: a[Attribute.heading],
      technique: a[Attribute.technique],
      decisions: a[Attribute.decisions],
      positioning: a[Attribute.positioning],
      vision: a[Attribute.vision],
      composure: a[Attribute.composure],
      workRate: a[Attribute.workRate],
      aggression: a[Attribute.aggression],
      pace: a[Attribute.pace],
      acceleration: a[Attribute.acceleration],
      stamina: a[Attribute.stamina],
      strength: a[Attribute.strength],
      agility: a[Attribute.agility],
      handling: a[Attribute.handling],
      reflexes: a[Attribute.reflexes],
      oneOnOnes: a[Attribute.oneOnOnes],
      aerialReach: a[Attribute.aerialReach],
      potentialAbility: p.potentialAbility,
      currentAbility: p.currentAbility,
      condition: p.condition,
      morale: p.morale,
      marketValue: p.marketValue,
    );
  }
}
