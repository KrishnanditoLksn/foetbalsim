import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/enums/squad_status.dart';
import 'package:futbol/domain/transfer/agent_negotiator.dart';

/// Mesin tawar-menawar Ruang Negosiasi (README_NEGOTIATION_ROOM B & F).
void main() {
  const names = NegotiationNames(player: 'Ruiz', club: 'Sevilla');

  AgentProfile agentWith(AgentStyle style) {
    for (var id = 1; id < 5000; id++) {
      final a = AgentProfile.forPlayer(seed: 7, playerId: id);
      if (a.style == style) return a;
    }
    throw StateError('gaya $style tidak ditemukan');
  }

  NegotiationSession buy({
    AgentStyle style = AgentStyle.professional,
    int anchor = 12000,
    int limit = 9200,
  }) => AgentNegotiator.open(
    mode: NegotiationMode.transferBuy,
    agent: agentWith(style),
    anchor: anchor,
    limit: limit,
    agentTerms: const NegotiationOffer(amount: 8500),
    names: names,
    userOpening: const NegotiationOffer(amount: 8500),
  );

  group('Profil agen', () {
    test('deterministik dari seed dan id pemain', () {
      final a = AgentProfile.forPlayer(seed: 99, playerId: 42);
      final b = AgentProfile.forPlayer(seed: 99, playerId: 42);
      expect(a.name, b.name);
      expect(a.style, b.style);
      expect(a.openingMargin, b.openingMargin);
      expect(a.roundPenalty, b.roundPenalty);
    });

    test('tiap pemain punya agen sendiri dan ketiga gaya muncul', () {
      final agents = [
        for (var id = 1; id <= 200; id++)
          AgentProfile.forPlayer(seed: 99, playerId: id),
      ];
      expect(agents.map((a) => a.style).toSet(), AgentStyle.values.toSet());
      expect(agents.map((a) => a.name).toSet().length, greaterThan(50));
    });

    test('margin pembuka 10–25%, keras kepala lebih cepat habis sabar', () {
      for (var id = 1; id <= 300; id++) {
        final a = AgentProfile.forPlayer(seed: 3, playerId: id);
        expect(a.openingMargin, inInclusiveRange(0.10, 0.25));
        expect(a.ceilingRatio, inInclusiveRange(1.05, 1.25));
      }
      final soft = agentWith(AgentStyle.compromising);
      final hard = agentWith(AgentStyle.stubborn);
      // Hanya penalti ronde: kompromistis 4–5 tawaran, keras kepala 2–3.
      expect((100 / soft.roundPenalty).ceil(), inInclusiveRange(4, 6));
      expect((100 / hard.roundPenalty).ceil(), inInclusiveRange(2, 3));
    });
  });

  group('Patokan & kesepakatan', () {
    test('sesi dibuka dengan patokan dan kalimat pembuka agen', () {
      final s = buy();
      expect(s.patience, 100);
      expect(AgentNegotiator.anchorOffer(s).amount, 12000);
      expect(s.log.last.byAgent, isTrue);
      expect(s.log.last.text, contains('Sevilla'));
      expect(s.log.first.text, contains('Tawaran awal Anda'));
    });

    test('tawaran ≥ batas dan ≤ 3% dari patokan diterima', () {
      final s = buy(anchor: 10000, limit: 9200);
      final r = AgentNegotiator.respond(
        s,
        const NegotiationOffer(amount: 9700),
        names,
      );
      expect(r.verdict, AgentVerdict.accept);
      expect(r.session.status, NegotiationStatus.agreed);
      expect(r.agreedOffer!.amount, 9700);
    });

    test('tawaran di bawah batas rahasia tidak diterima walau dekat patokan', () {
      final s = buy(anchor: 9300, limit: 9300);
      final r = AgentNegotiator.respond(
        s,
        const NegotiationOffer(amount: 9100),
        names,
      );
      expect(r.verdict, AgentVerdict.counter);
    });

    test('kontra mendekati tawaran user tapi tidak melewati batas', () {
      final s = buy(anchor: 12000, limit: 9200);
      final r = AgentNegotiator.respond(
        s,
        const NegotiationOffer(amount: 10500),
        names,
      );
      expect(r.verdict, AgentVerdict.counter);
      expect(r.session.anchor, lessThan(12000));
      expect(r.session.anchor, greaterThanOrEqualTo(10500));
      expect(r.session.patience, lessThan(100));
      expect(r.message, isNotEmpty);
    });

    test('beberapa ronde wajar berakhir sepakat', () {
      var s = buy(style: AgentStyle.compromising, anchor: 11000, limit: 9500);
      var offer = 9800;
      AgentResponse? r;
      for (var i = 0; i < 6; i++) {
        r = AgentNegotiator.respond(s, NegotiationOffer(amount: offer), names);
        if (r.verdict != AgentVerdict.counter) break;
        s = r.session;
        // User menaikkan tawaran mendekati patokan baru.
        offer = ((offer + s.anchor) / 2).round();
      }
      expect(r!.verdict, AgentVerdict.accept);
    });
  });

  group('Kesabaran (README B.3)', () {
    test('tawaran menghina berulang memicu walk-out', () {
      var s = buy(style: AgentStyle.professional);
      AgentResponse? r;
      for (var i = 0; i < 5; i++) {
        r = AgentNegotiator.respond(s, const NegotiationOffer(amount: 6000), names);
        expect(r.lowball, isTrue);
        if (r.verdict == AgentVerdict.walkOut) break;
        // Tawaran menghina tidak dibalas dengan potongan.
        expect(r.session.anchor, s.anchor);
        s = r.session;
      }
      expect(r!.verdict, AgentVerdict.walkOut);
      expect(r.session.patience, 0);
      expect(r.session.status, NegotiationStatus.walkedOut);
      expect(r.session.lowballs, greaterThan(0));
    });

    test('penalti jarak: ≤10% tanpa tambahan, 11–25% −10, >25% berat', () {
      final s = buy(anchor: 10000, limit: 9000);
      final base = s.agent.roundPenalty;
      int delta(int amount) =>
          AgentNegotiator.respond(s, NegotiationOffer(amount: amount), names)
              .patienceDelta;
      expect(delta(9100), -base);
      expect(delta(8000), -base - 10);
      expect(delta(7000), -base - s.agent.lowballPenalty);
    });

    test('bonus konsesi hanya bila syarat lebih baik dari tawaran sebelumnya', () {
      const prev = NegotiationOffer(amount: 9000, installmentYears: 2);
      expect(
        AgentNegotiator.concessionBonus(
          NegotiationMode.transferBuy,
          prev,
          const NegotiationOffer(amount: 9000, sellOnPct: 10),
          3,
        ),
        10, // dibayar langsung + sell-on
      );
      expect(
        AgentNegotiator.concessionBonus(
          NegotiationMode.transferBuy,
          prev,
          const NegotiationOffer(amount: 9000, installmentYears: 3, sellOnPct: 10),
          3,
        ),
        0, // cicilan memburuk
      );
      expect(
        AgentNegotiator.concessionBonus(
          NegotiationMode.transferBuy,
          null,
          const NegotiationOffer(amount: 9000, sellOnPct: 30),
          3,
        ),
        0, // tanpa tawaran sebelumnya
      );
    });

    test('warna meter: hijau ≥60, kuning 25–59, merah 1–24', () {
      expect(AgentNegotiator.levelOf(60), PatienceLevel.open);
      expect(AgentNegotiator.levelOf(59), PatienceLevel.impatient);
      expect(AgentNegotiator.levelOf(25), PatienceLevel.impatient);
      expect(AgentNegotiator.levelOf(24), PatienceLevel.critical);
      expect(AgentNegotiator.levelOf(0), PatienceLevel.gone);
    });
  });

  group('Tukar-tambah syarat', () {
    test('sell-on dan pembayaran langsung menurunkan nominal yang diminta', () {
      final s = buy(anchor: 10000, limit: 9000);
      final plain = AgentNegotiator.anchorOffer(
        s,
        const NegotiationOffer(amount: 0),
      );
      final sellOn = AgentNegotiator.anchorOffer(
        s,
        const NegotiationOffer(amount: 0, sellOnPct: 20),
      );
      final instalments = AgentNegotiator.anchorOffer(
        s,
        const NegotiationOffer(amount: 0, installmentYears: 3),
      );
      expect(sellOn.amount, lessThan(plain.amount));
      expect(instalments.amount, greaterThan(plain.amount));
    });

    test('peran lebih besar meringankan gaji 5–10%', () {
      final s = AgentNegotiator.open(
        mode: NegotiationMode.contract,
        agent: agentWith(AgentStyle.professional),
        anchor: 1000,
        limit: 900,
        agentTerms: const NegotiationOffer(amount: 1000, contractYears: 4),
        names: names,
        preferredYears: 4,
      );
      int wageAs(SquadStatus r) => AgentNegotiator.anchorOffer(
        s,
        NegotiationOffer(amount: 0, contractYears: 4, squadStatus: r),
      ).amount;
      final rotation = wageAs(SquadStatus.rotation);
      final starter = wageAs(SquadStatus.starter);
      final key = wageAs(SquadStatus.keyPlayer);
      expect(rotation, 1000);
      expect(starter / rotation, closeTo(0.95, 0.01));
      expect(key / rotation, closeTo(0.91, 0.01));
    });

    test('durasi sesuai usia: muda 5 thn, veteran 2 thn', () {
      expect(AgentNegotiator.preferredYears(21), 5);
      expect(AgentNegotiator.preferredYears(26), 4);
      expect(AgentNegotiator.preferredYears(33), 2);
    });

    test('mode jual: pembeli naik bertahap sampai batas atasnya', () {
      var s = AgentNegotiator.open(
        mode: NegotiationMode.transferSell,
        agent: agentWith(AgentStyle.compromising),
        anchor: 10000,
        limit: 11500,
        agentTerms: const NegotiationOffer(amount: 10000),
        names: names,
      );
      final r1 = AgentNegotiator.respond(
        s,
        const NegotiationOffer(amount: 12000),
        names,
      );
      expect(r1.verdict, AgentVerdict.counter);
      expect(r1.session.anchor, greaterThan(10000));
      expect(r1.session.anchor, lessThanOrEqualTo(11500));
      s = r1.session;
      final r2 = AgentNegotiator.respond(
        s,
        NegotiationOffer(amount: AgentNegotiator.anchorOffer(s).amount),
        names,
      );
      expect(r2.verdict, AgentVerdict.accept);
    });
  });

  test('sesi tersimpan dan dimuat ulang tanpa kehilangan progres', () {
    final s = buy();
    final r = AgentNegotiator.respond(
      s,
      const NegotiationOffer(amount: 10000, sellOnPct: 10),
      names,
    );
    final stored = r.session;
    final loaded = NegotiationSession.fromStored(
      mode: stored.mode,
      agent: stored.agent,
      status: stored.status,
      patience: stored.patience,
      anchor: stored.anchor,
      limit: stored.limit,
      extras: stored.extrasJson(),
    );
    expect(loaded.patience, stored.patience);
    expect(loaded.anchor, stored.anchor);
    expect(loaded.turns, 1);
    expect(loaded.lastOffer!.sellOnPct, 10);
    expect(loaded.log.length, stored.log.length);
    expect(loaded.log.last.text, stored.log.last.text);
  });
}
