import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/enums/position.dart';
import 'package:futbol/domain/enums/squad_status.dart';
import 'package:futbol/domain/generators/world_generator.dart';
import 'package:futbol/domain/models/game_models.dart';
import 'package:futbol/domain/transfer/club_ai_profile.dart';
import 'package:futbol/domain/transfer/interest_engine.dart';
import 'package:futbol/domain/transfer/market_heat.dart';
import 'package:futbol/domain/transfer/negotiation_ai.dart';
import 'package:futbol/domain/transfer/player_willingness.dart';
import 'package:futbol/domain/transfer/squad_needs.dart';
import 'package:futbol/domain/transfer/transfer_window.dart';
import 'package:futbol/domain/transfer/valuation.dart';
import 'package:futbol/domain/models/player_attributes.dart';
import 'package:futbol/domain/enums/attribute.dart';

Player _player({
  int id = 1,
  int age = 25,
  int ca = 120,
  int value = 10000,
  bool listed = false,
  Position position = Position.st,
  int morale = 60,
}) => Player(
  id: id,
  clubId: 'x',
  firstName: 'A',
  lastName: 'B$id',
  age: age,
  nationality: 'ESP',
  position: position,
  attributes: PlayerAttributes({for (final a in Attribute.values) a: 10}),
  potentialAbility: 150,
  currentAbility: ca,
  condition: 90,
  morale: morale,
  marketValue: value,
  isTransferListed: listed,
);

ClubAiProfile _profile({
  ClubPersonality p = ClubPersonality.moneyball,
  int skill = 50,
}) => ClubAiProfile(
  clubId: 'c',
  personality: p,
  ambition: 50,
  riskTolerance: 50,
  negotiationSkill: skill,
  sellingWillingness: 50,
  youthFocus: 50,
);

void main() {
  group('Valuasi dinamis (README B.4)', () {
    final now = DateTime.utc(2026, 9, 10);
    test('kontrak sisa ≤ 1 tahun lebih murah dari kontrak panjang', () {
      final short = Contract(
        playerId: 1,
        clubId: 'x',
        wage: 1000,
        endDate: DateTime.utc(2027, 6, 30),
        squadStatus: SquadStatus.rotation,
      );
      final long = Contract(
        playerId: 1,
        clubId: 'x',
        wage: 1000,
        endDate: DateTime.utc(2031, 6, 30),
        squadStatus: SquadStatus.rotation,
      );
      final a = DynamicValuation.askingFee(
        player: _player(),
        contract: short,
        now: now,
      );
      final b = DynamicValuation.askingFee(
        player: _player(),
        contract: long,
        now: now,
      );
      expect(a, lessThan(b));
    });

    test('Deadline Day menaikkan harga dibanding hari biasa', () {
      final normal = MarketHeat.multiplier(
        date: DateTime.utc(2026, 8, 10),
        positionDemand: 0.5,
      );
      final deadline = MarketHeat.multiplier(
        date: DateTime.utc(2026, 8, 30),
        positionDemand: 0.5,
      );
      expect(deadline, greaterThan(normal));
      expect(deadline, lessThanOrEqualTo(1.4));
      expect(TransferWindow.isDeadlineDay(DateTime.utc(2026, 8, 30)), isTrue);
      expect(TransferWindow.isDeadlineDay(DateTime.utc(2026, 8, 10)), isFalse);
    });

    test('pemain inti lebih mahal dari cadangan', () {
      final core = DynamicValuation.askingFee(
        player: _player(),
        contract: Contract(
          playerId: 1,
          clubId: 'x',
          wage: 1000,
          endDate: DateTime.utc(2029, 6, 30),
          squadStatus: SquadStatus.keyPlayer,
        ),
        now: now,
      );
      final backup = DynamicValuation.askingFee(
        player: _player(),
        contract: Contract(
          playerId: 1,
          clubId: 'x',
          wage: 1000,
          endDate: DateTime.utc(2029, 6, 30),
          squadStatus: SquadStatus.backup,
        ),
        now: now,
      );
      expect(core, greaterThan(backup));
    });
  });

  group('Evaluasi tawaran pertama (README B.5 & E.4)', () {
    test('tawaran di bawah 70% harga minta ditolak', () {
      final r = NegotiationAi.evaluate(
        offer: 6900,
        ask: 10000,
        seller: _profile(),
        isIndispensable: false,
      );
      expect(r.verdict, NegotiationVerdict.reject);
      expect(r.reason, isNotNull);
    });

    test('tawaran 85–99% mendapat counter-offer', () {
      for (final offer in [8500, 9000, 9900]) {
        final r = NegotiationAi.evaluate(
          offer: offer,
          ask: 10000,
          seller: _profile(),
          isIndispensable: false,
        );
        expect(r.verdict, NegotiationVerdict.counter, reason: '$offer');
        expect(r.counterFee, inInclusiveRange(9000, 10000));
      }
    });

    test('tawaran ≥ harga minta diterima', () {
      final r = NegotiationAi.evaluate(
        offer: 10000,
        ask: 10000,
        seller: _profile(),
        isIndispensable: false,
      );
      expect(r.verdict, NegotiationVerdict.accept);
    });

    test('pemain inti tanpa pengganti butuh 110% harga minta', () {
      final low = NegotiationAi.evaluate(
        offer: 10500,
        ask: 10000,
        seller: _profile(),
        isIndispensable: true,
      );
      expect(low.verdict, NegotiationVerdict.reject);
      final high = NegotiationAi.evaluate(
        offer: 11000,
        ask: 10000,
        seller: _profile(),
        isIndispensable: true,
      );
      expect(high.verdict, NegotiationVerdict.accept);
    });
  });

  group('Minat & kemauan pemain (README B.10)', () {
    test('skor minat memakai bobot 35/25/15/15/10', () {
      final s = InterestEngine.score(
        needFit: 100,
        upgrade: 0,
        profileFit: 0,
        affordability: 0,
        opportunity: 0,
      );
      expect(s, 35);
      expect(InterestEngine.levelFor(35), InterestLevel.none);
      expect(InterestEngine.levelFor(45), InterestLevel.watching);
      expect(InterestEngine.levelFor(65), InterestLevel.interested);
      expect(InterestEngine.levelFor(85), InterestLevel.target);
    });

    test('minat meluruh 5 poin per minggu', () {
      expect(InterestEngine.decay(70), 65);
      expect(InterestEngine.decay(70, weeks: 4), 50);
    });

    test('pemain inti menolak turun kelas tanpa kenaikan gaji besar', () {
      final r = PlayerWillingness.decide(
        player: _player(age: 26),
        fromRep: 85,
        toRep: 60,
        wageOffer: 1000,
        expectedWage: 1000,
        isBenchPlayer: false,
        shortContractInJanuary: false,
      );
      expect(r.willing, isFalse);
    });

    test('cadangan mau pindah sekelas demi menit bermain', () {
      final r = PlayerWillingness.decide(
        player: _player(age: 24),
        fromRep: 80,
        toRep: 78,
        wageOffer: 800,
        expectedWage: 1000,
        isBenchPlayer: true,
        shortContractInJanuary: false,
      );
      expect(r.willing, isTrue);
    });

    test('kontrak ≤ 6 bulan di jendela Januari menolak semua tawaran', () {
      final r = PlayerWillingness.decide(
        player: _player(),
        fromRep: 50,
        toRep: 90,
        wageOffer: 99999,
        expectedWage: 1000,
        isBenchPlayer: false,
        shortContractInJanuary: true,
      );
      expect(r.willing, isFalse);
    });
  });

  group('Profil & kebutuhan skuad (README B.2–B.3)', () {
    final seedJson = File('assets/seed/spain.json').readAsStringSync();
    final world = WorldGenerator.generate(seedJson: seedJson, seed: 11);

    test('profil klub deterministik dari seed dan nama klub', () {
      final club = world.clubs.first;
      final a = ClubAiProfile.derive(club: club, seed: 5);
      final b = ClubAiProfile.derive(club: club, seed: 5);
      expect(a.personality, b.personality);
      expect(a.negotiationSkill, b.negotiationSkill);
      expect(a.ambition, inInclusiveRange(0, 100));
    });

    test('klub saldo minus menjadi Survival Mode', () {
      final club = world.clubs.first;
      final broke = Club(
        id: club.id,
        leagueId: club.leagueId,
        name: club.name,
        shortName: club.shortName,
        primaryColor: club.primaryColor,
        secondaryColor: club.secondaryColor,
        reputation: club.reputation,
        stadiumName: club.stadiumName,
        capacity: club.capacity,
        balance: -100,
        transferBudget: 0,
        wageBudget: club.wageBudget,
      );
      expect(
        ClubAiProfile.derive(club: broke, seed: 1).personality,
        ClubPersonality.survivalMode,
      );
    });

    test('kebutuhan skuad lebih tinggi untuk grup yang kurang pemain', () {
      final squad = [
        for (var i = 0; i < 8; i++)
          _player(id: i + 1, position: Position.dc, ca: 110),
      ];
      final needs = SquadNeeds.analyze(
        squad: squad,
        contracts: {},
        now: DateTime.utc(2026, 9, 1),
        benchmarkCa: 110,
      );
      expect(needs[PositionGroup.goalkeeper], greaterThan(0));
      expect(needs[PositionGroup.forward], greaterThan(0));
    });
  });
}
