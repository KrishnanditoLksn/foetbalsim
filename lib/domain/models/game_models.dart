import '../enums/position.dart';
import '../enums/squad_status.dart';
import 'player_attributes.dart';

class Nation {
  const Nation({required this.id, required this.name, required this.code});

  final String id;
  final String name;
  final String code;
}

class League {
  const League({
    required this.id,
    required this.nationId,
    required this.name,
    required this.tier,
    required this.jumlahTim,
    required this.slotPromosi,
    required this.slotDegradasi,
    required this.slotPlayoff,
  });

  final String id;
  final String nationId;
  final String name;
  final int tier;
  final int jumlahTim;
  final int slotPromosi;
  final int slotDegradasi;
  final int slotPlayoff;
}

class Club {
  const Club({
    required this.id,
    required this.leagueId,
    required this.name,
    required this.shortName,
    required this.primaryColor,
    required this.secondaryColor,
    required this.reputation,
    required this.stadiumName,
    required this.capacity,
    required this.balance,
    required this.transferBudget,
    required this.wageBudget,
  });

  final String id;
  final String leagueId;
  final String name;
  final String shortName;
  final String primaryColor; // "#RRGGBB"
  final String secondaryColor;
  final int reputation; // 1–100
  final String stadiumName;
  final int capacity;
  final int balance; // €K
  final int transferBudget; // €K
  final int wageBudget; // €K per tahun
}

class Player {
  const Player({
    required this.id,
    required this.clubId,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.nationality,
    required this.position,
    required this.attributes,
    required this.potentialAbility,
    required this.currentAbility,
    required this.condition,
    required this.morale,
    required this.marketValue,
    this.isTransferListed = false,
    this.lockedUntil,
  });

  final int id;
  final String clubId;
  final String firstName;
  final String lastName;
  final int age;
  final String nationality;
  final Position position;
  final PlayerAttributes attributes;
  final int potentialAbility; // 1–200
  final int currentAbility; // 1–200
  final int condition; // 0–100
  final int morale; // 0–100
  final int marketValue; // €K
  final bool isTransferListed; // masuk daftar jual
  final DateTime? lockedUntil; // terkunci sampai tanggal ini (baru pindah)

  String get fullName => '$firstName $lastName';
}

class Contract {
  const Contract({
    required this.playerId,
    required this.clubId,
    required this.wage,
    required this.endDate,
    required this.squadStatus,
  });

  final int playerId;
  final String clubId;
  final int wage; // €K per tahun
  final DateTime endDate;
  final SquadStatus squadStatus;
}

class GameState {
  const GameState({
    required this.currentDate,
    required this.managerName,
    required this.clubId,
    required this.seed,
  });

  final DateTime currentDate;
  final String managerName;
  final String? clubId;
  final int seed;
}

/// Hasil generate dunia baru (belum ditulis ke database).
class WorldBlueprint {
  const WorldBlueprint({
    required this.nations,
    required this.leagues,
    required this.clubs,
    required this.players,
    required this.contracts,
  });

  final List<Nation> nations;
  final List<League> leagues;
  final List<Club> clubs;
  final List<Player> players;
  final List<Contract> contracts;
}
