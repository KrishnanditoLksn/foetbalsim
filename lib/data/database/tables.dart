import 'package:drift/drift.dart';

import '../../domain/enums/inbox.dart';
import '../../domain/enums/position.dart';
import '../../domain/enums/squad_status.dart';

@DataClassName('NationRow')
class Nations extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get code => text().withLength(min: 3, max: 3)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('LeagueRow')
class Leagues extends Table {
  TextColumn get id => text()();
  TextColumn get nationId => text()();
  TextColumn get name => text()();
  IntColumn get tier => integer()();
  IntColumn get jumlahTim => integer()();
  IntColumn get slotPromosi => integer()();
  IntColumn get slotDegradasi => integer()();
  IntColumn get slotPlayoff => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ClubRow')
class Clubs extends Table {
  TextColumn get id => text()();
  TextColumn get leagueId => text()();
  TextColumn get name => text()();
  TextColumn get shortName => text().withLength(min: 3, max: 3)();
  TextColumn get primaryColor => text()();
  TextColumn get secondaryColor => text()();
  IntColumn get reputation => integer()();
  TextColumn get stadiumName => text()();
  IntColumn get capacity => integer()();
  IntColumn get balance => integer()(); // €K
  IntColumn get transferBudget => integer()(); // €K
  IntColumn get wageBudget => integer()(); // €K

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PlayerRow')
class Players extends Table {
  IntColumn get id => integer()();
  TextColumn get clubId => text()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  IntColumn get age => integer()();
  TextColumn get nationality => text()();
  TextColumn get position => textEnum<Position>()();

  // Teknik
  IntColumn get finishing => integer()();
  IntColumn get passing => integer()();
  IntColumn get dribbling => integer()();
  IntColumn get firstTouch => integer()();
  IntColumn get crossing => integer()();
  IntColumn get tackling => integer()();
  IntColumn get heading => integer()();
  IntColumn get technique => integer()();
  // Mental
  IntColumn get decisions => integer()();
  IntColumn get positioning => integer()();
  IntColumn get vision => integer()();
  IntColumn get composure => integer()();
  IntColumn get workRate => integer()();
  IntColumn get aggression => integer()();
  // Fisik
  IntColumn get pace => integer()();
  IntColumn get acceleration => integer()();
  IntColumn get stamina => integer()();
  IntColumn get strength => integer()();
  IntColumn get agility => integer()();
  // Kiper
  IntColumn get handling => integer()();
  IntColumn get reflexes => integer()();
  IntColumn get oneOnOnes => integer()();
  IntColumn get aerialReach => integer()();

  IntColumn get potentialAbility => integer()();
  IntColumn get currentAbility => integer()();
  IntColumn get condition => integer()();
  IntColumn get morale => integer()();
  IntColumn get marketValue => integer()(); // €K

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ContractRow')
class Contracts extends Table {
  IntColumn get playerId => integer()();
  TextColumn get clubId => text()();
  IntColumn get wage => integer()(); // €K per tahun
  DateTimeColumn get endDate => dateTime()();
  TextColumn get squadStatus => textEnum<SquadStatus>()();

  @override
  Set<Column> get primaryKey => {playerId};
}

/// Satu baris saja (id = 1) per file save.
@DataClassName('GameStateRow')
class GameStates extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  DateTimeColumn get currentDate => dateTime()();
  TextColumn get managerName => text()();
  TextColumn get clubId => text().nullable()();
  IntColumn get seed => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Jadwal pertandingan satu musim (kedua liga). Skor null = belum dimainkan.
@DataClassName('FixtureRow')
class Fixtures extends Table {
  IntColumn get id => integer()();
  TextColumn get leagueId => text()();
  IntColumn get round => integer()();
  DateTimeColumn get date => dateTime()();
  TextColumn get homeClubId => text()();
  TextColumn get awayClubId => text()();
  IntColumn get homeGoals => integer().nullable()();
  IntColumn get awayGoals => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Inbox: sambutan dewan, laporan laga, kontrak, dan keputusan lainnya.
@DataClassName('InboxRow')
class InboxMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get category => textEnum<InboxCategory>()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  TextColumn get actionType => textEnum<InboxActionType>()();
  TextColumn get payload => text().nullable()();
  BoolColumn get resolved => boolean().withDefault(const Constant(false))();
  TextColumn get choice => text().nullable()();
}
