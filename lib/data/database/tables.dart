import 'package:drift/drift.dart';

import '../../domain/enums/inbox.dart';
import '../../domain/enums/position.dart';
import '../../domain/enums/squad_status.dart';
import '../../domain/enums/tactics.dart';
import '../../domain/enums/transfer.dart';

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
  DateTimeColumn get lockedUntil => dateTime().nullable()(); // v4: tidak bisa pindah dua kali
  BoolColumn get isTransferListed =>
      boolean().withDefault(const Constant(false))(); // v3

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
  IntColumn get seasonStartYear => integer().withDefault(const Constant(2026))(); // v4

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
  IntColumn get seasonStartYear => integer().withDefault(const Constant(2026))(); // v4
  TextColumn get stage => text().withDefault(const Constant('league'))(); // v4: league / playoffSemi / playoffFinal
  IntColumn get leg => integer().nullable()(); // v4: 1 atau 2 pada playoff
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

/// Taktik per klub (v3). Daftar id disimpan sebagai teks "1,2,3".
@DataClassName('ClubTacticRow')
class ClubTactics extends Table {
  TextColumn get clubId => text()();
  TextColumn get formation => textEnum<Formation>()();
  TextColumn get mentality => textEnum<Mentality>()();
  TextColumn get starterIds => text().withDefault(const Constant(''))();
  TextColumn get subIds => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {clubId};
}

/// Tawaran transfer (v3). fromClubId = penawar, toClubId = penjual.
@DataClassName('TransferOfferRow')
class TransferOffers extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get playerId => integer()();
  TextColumn get fromClubId => text()();
  TextColumn get toClubId => text()();
  IntColumn get fee => integer()(); // €K
  TextColumn get status => textEnum<TransferOfferStatus>()();
  DateTimeColumn get createdDate => dateTime()();
  DateTimeColumn get responseDate => dateTime().nullable()();
  IntColumn get installmentYears => integer().withDefault(const Constant(1))(); // v4
  IntColumn get sellOnPct => integer().withDefault(const Constant(0))(); // v4
  IntColumn get round => integer().withDefault(const Constant(1))(); // v4: 1 = tawaran, 2 = kontra
  DateTimeColumn get expiresDate => dateTime().nullable()(); // v4
  TextColumn get reason => text().nullable()(); // v4: alasan penolakan
  TextColumn get kind => text().withDefault(const Constant("permanent"))(); // v4: jenis kesepakatan
}

/// Riwayat transfer (v3).
@DataClassName('TransferHistoryRow')
class TransferHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  IntColumn get playerId => integer()();
  TextColumn get playerName => text()();
  TextColumn get fromClubId => text()();
  TextColumn get toClubId => text()();
  IntColumn get fee => integer()(); // €K
  TextColumn get type => textEnum<TransferType>()();
}

/// Daftar pantau pemain (v3).
@DataClassName('ShortlistRow')
class Shortlist extends Table {
  IntColumn get playerId => integer()();
  DateTimeColumn get addedDate => dateTime()();

  @override
  Set<Column> get primaryKey => {playerId};
}

/// Profil kepribadian klub AI (README_FASE3 B.2). Satu baris per klub.
@DataClassName('ClubAiProfileRow')
class ClubAiProfiles extends Table {
  TextColumn get clubId => text()();
  TextColumn get personality => text()();
  IntColumn get ambition => integer()();
  IntColumn get riskTolerance => integer()();
  IntColumn get negotiationSkill => integer()();
  IntColumn get sellingWillingness => integer()();
  IntColumn get youthFocus => integer()();

  @override
  Set<Column> get primaryKey => {clubId};
}

/// Skor minat klub terhadap pemain (README_FASE3 B.10.3).
@DataClassName('TransferInterestRow')
class TransferInterests extends Table {
  TextColumn get clubId => text()();
  IntColumn get playerId => integer()();
  IntColumn get score => integer()();
  TextColumn get level => text()();
  DateTimeColumn get updatedDate => dateTime()();

  @override
  Set<Column> get primaryKey => {clubId, playerId};
}

/// Berita bursa: rumor, kesepakatan, tawaran, dan penanda deadline.
@DataClassName('TransferNewsRow')
class TransferNews extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get kind => text()();
  TextColumn get body => text()();
  TextColumn get clubIds => text().withDefault(const Constant(''))();
}

/// Memori perilaku user untuk adaptasi AI (README_FASE3 B.7).
@DataClassName('MarketMemoryRow')
class MarketMemory extends Table {
  TextColumn get key => text()();
  IntColumn get value => integer()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Musim yang pernah dimainkan (README_SEASON_CALENDAR §4).
@DataClassName('SeasonRow')
class Seasons extends Table {
  IntColumn get startYear => integer()();
  TextColumn get label => text()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  TextColumn get status => text()();

  @override
  Set<Column> get primaryKey => {startYear};
}

/// Klasemen akhir per musim per klub.
@DataClassName('SeasonArchiveRow')
class SeasonArchive extends Table {
  IntColumn get seasonStartYear => integer()();
  TextColumn get leagueId => text()();
  TextColumn get clubId => text()();
  IntColumn get position => integer()();
  IntColumn get played => integer()();
  IntColumn get won => integer()();
  IntColumn get drawn => integer()();
  IntColumn get lost => integer()();
  IntColumn get gf => integer()();
  IntColumn get ga => integer()();
  IntColumn get points => integer()();

  @override
  Set<Column> get primaryKey => {seasonStartYear, clubId};
}

/// Gelar dan penghargaan klub (juara, promosi, degradasi, dll.).
@DataClassName('HonourRow')
class Honours extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get seasonStartYear => integer()();
  TextColumn get leagueId => text()();
  TextColumn get type => text()();
  TextColumn get clubId => text()();
  IntColumn get playerId => integer().nullable()();
}
