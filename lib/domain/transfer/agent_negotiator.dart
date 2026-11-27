import 'dart:convert';

import '../../core/rng/seeded_random.dart';
import '../../l10n/l10n.dart';
import '../enums/squad_status.dart';
import 'transfer_rules.dart';

/// Ruang negosiasi (README_NEGOTIATION_ROOM): tawar-menawar langsung dengan
/// agen pemain. Setiap pemain punya agen dengan kebijakannya sendiri,
/// diturunkan dari `seed` dan id pemain, sehingga sama sepanjang karier.
///
/// Semua nilai di sini murni dan deterministik: tidak ada angka acak per
/// ronde. Layanan transfer menghitung batas rahasia dan menyimpan sesi.

/// Apa yang sedang dirundingkan.
enum NegotiationMode {
  /// Kita membeli: agen meminta biaya transfer setinggi mungkin.
  transferBuy,

  /// Kita menjual: agen menyampaikan tawaran klub pembeli, ingin serendah
  /// mungkin.
  transferSell,

  /// Kontrak pemain yang akan bergabung: agen meminta gaji setinggi mungkin.
  contract;

  /// Agen diuntungkan oleh angka yang lebih tinggi.
  bool get agentWantsMore => this != NegotiationMode.transferSell;
}

/// Gaya agen menentukan kesabaran, potongan tiap ronde, dan nada bicara.
enum AgentStyle {
  compromising,
  professional,
  stubborn;

  String get label => tr('agentStyle.$name');
}

/// Profil agen satu pemain (README B.1).
class AgentProfile {
  const AgentProfile({
    required this.name,
    required this.style,
    required this.openingMargin,
    required this.roundPenalty,
    required this.lowballTolerance,
    required this.lowballPenalty,
    required this.concession,
    required this.floorShift,
    required this.ceilingRatio,
  });

  final String name;
  final AgentStyle style;

  /// Seberapa tinggi patokan awal di atas nilai target (0,10–0,25).
  final double openingMargin;

  /// Kesabaran yang hilang setiap kali user mengajukan tawaran.
  final int roundPenalty;

  /// Selisih (rasio) dari patokan yang dianggap menghina.
  final double lowballTolerance;

  /// Kesabaran yang hilang untuk tawaran yang menghina.
  final int lowballPenalty;

  /// Bagian jarak ke tawaran user yang ditutup agen setiap kontra (0–1).
  final double concession;

  /// Geseran batas bawah penjual: agen keras kepala melepas lebih sedikit.
  final double floorShift;

  /// Batas atas klub pembeli dibanding tawaran pembukanya (1,05–1,25).
  final double ceilingRatio;

  /// Profil deterministik dari `seed` dan id pemain.
  static AgentProfile forPlayer({required int seed, required int playerId}) {
    final rng = SeededRandom(seed ^ ((playerId + 1) * 0x9E3779B1));
    // Lompati beberapa angka pertama agar seed yang berdekatan tetap beragam.
    for (var i = 0; i < 3; i++) {
      rng.nextU32();
    }
    final roll = rng.nextDouble();
    final style =
        roll < 0.35
            ? AgentStyle.compromising
            : roll < 0.75
            ? AgentStyle.professional
            : AgentStyle.stubborn;
    final name = '${rng.pick(_firstNames)} ${rng.pick(_lastNames)}';
    double between(double a, double b) => a + (b - a) * rng.nextDouble();
    return switch (style) {
      AgentStyle.compromising => AgentProfile(
        name: name,
        style: style,
        openingMargin: between(0.10, 0.15),
        roundPenalty: rng.range(19, 22),
        lowballTolerance: 0.25,
        lowballPenalty: 30,
        concession: 0.5,
        floorShift: -0.02,
        ceilingRatio: between(1.18, 1.25),
      ),
      AgentStyle.professional => AgentProfile(
        name: name,
        style: style,
        openingMargin: between(0.14, 0.20),
        roundPenalty: rng.range(25, 30),
        lowballTolerance: 0.25,
        lowballPenalty: 38,
        concession: 0.35,
        floorShift: 0,
        ceilingRatio: between(1.12, 1.18),
      ),
      AgentStyle.stubborn => AgentProfile(
        name: name,
        style: style,
        openingMargin: between(0.18, 0.25),
        roundPenalty: rng.range(34, 42),
        lowballTolerance: 0.25,
        lowballPenalty: 45,
        concession: 0.2,
        floorShift: 0.02,
        ceilingRatio: between(1.05, 1.12),
      ),
    };
  }

  static const _firstNames = [
    'Carlos',
    'Jorge',
    'Paulo',
    'Miguel',
    'Andrés',
    'Luis',
    'Rafael',
    'Sergio',
    'Marco',
    'Federico',
    'Hugo',
    'Tomás',
    'Nuno',
    'Iker',
    'Mónica',
    'Lucía',
    'Elena',
    'Marta',
    'Pilar',
    'Ana',
  ];
  static const _lastNames = [
    'Mendoza',
    'Barros',
    'Ferreira',
    'Ortega',
    'Salgado',
    'Quintero',
    'Vidal',
    'Arriaga',
    'Navarro',
    'Pires',
    'Cabral',
    'Ibarra',
    'Lozano',
    'Montes',
    'Serrano',
    'Duarte',
    'Robles',
    'Aguirre',
  ];
}

/// Satu paket tawaran. [amount] adalah biaya transfer (€K) pada mode
/// transfer, atau gaji per tahun (€K) pada mode kontrak.
class NegotiationOffer {
  const NegotiationOffer({
    required this.amount,
    this.installmentYears = 1,
    this.sellOnPct = 0,
    this.contractYears = 3,
    this.squadStatus = SquadStatus.rotation,
  });

  final int amount;
  final int installmentYears;
  final int sellOnPct;
  final int contractYears;
  final SquadStatus squadStatus;

  NegotiationOffer copyWith({
    int? amount,
    int? installmentYears,
    int? sellOnPct,
    int? contractYears,
    SquadStatus? squadStatus,
  }) => NegotiationOffer(
    amount: amount ?? this.amount,
    installmentYears: installmentYears ?? this.installmentYears,
    sellOnPct: sellOnPct ?? this.sellOnPct,
    contractYears: contractYears ?? this.contractYears,
    squadStatus: squadStatus ?? this.squadStatus,
  );

  Map<String, Object> toJson() => {
    'a': amount,
    'i': installmentYears,
    's': sellOnPct,
    'y': contractYears,
    'r': squadStatus.name,
  };

  static NegotiationOffer fromJson(Map<String, dynamic> j) => NegotiationOffer(
    amount: j['a'] as int,
    installmentYears: j['i'] as int? ?? 1,
    sellOnPct: j['s'] as int? ?? 0,
    contractYears: j['y'] as int? ?? 3,
    squadStatus: SquadStatus.values.byName(j['r'] as String? ?? 'rotation'),
  );
}

/// Satu baris riwayat tawar-menawar.
class NegotiationTurn {
  const NegotiationTurn({required this.byAgent, required this.text});

  NegotiationTurn.msg({required this.byAgent, required Msg msg})
    : text = msg.encode();

  final bool byAgent;

  /// `Msg` yang di-encode (sesi lama: teks biasa). Tampilkan lewat [display].
  final String text;

  String get display => trText(text);

  Map<String, Object> toJson() => {'g': byAgent, 't': text};

  static NegotiationTurn fromJson(Map<String, dynamic> j) =>
      NegotiationTurn(byAgent: j['g'] as bool, text: j['t'] as String);
}

enum NegotiationStatus { active, agreed, walkedOut }

/// Keadaan satu sesi negosiasi. Nilai [anchor] dan [limit] dinyatakan dalam
/// "nilai di mata agen" (lihat [AgentNegotiator.valueOf]), bukan nominal
/// mentah, sehingga syarat lain (cicilan, sell-on, peran, durasi) bisa
/// ditukar dengan nominal.
class NegotiationSession {
  const NegotiationSession({
    required this.mode,
    required this.agent,
    required this.patience,
    required this.anchor,
    required this.limit,
    required this.preferredYears,
    required this.agentTerms,
    this.status = NegotiationStatus.active,
    this.turns = 0,
    this.lastOffer,
    this.lowballs = 0,
    this.log = const [],
  });

  final NegotiationMode mode;

  /// Agen pemain (diturunkan dari seed, tidak disimpan).
  final AgentProfile agent;

  /// 0–100. Habis = agen walk-out.
  final int patience;

  /// Patokan agen saat ini (nilai).
  final int anchor;

  /// Batas rahasia: terendah yang diterima penjual/pemain, atau tertinggi
  /// yang mau dibayar pembeli (nilai).
  final int limit;

  /// Durasi kontrak yang paling disukai pemain (mode kontrak).
  final int preferredYears;

  /// Syarat non-nominal yang diminta agen saat membuka (peran, durasi,
  /// cicilan); nominalnya dihitung ulang dari [anchor].
  final NegotiationOffer agentTerms;

  final NegotiationStatus status;

  /// Jumlah tawaran yang sudah diajukan user di sesi ini.
  final int turns;

  /// Tawaran user sebelumnya (untuk bonus konsesi).
  final NegotiationOffer? lastOffer;

  /// Jumlah tawaran menghina di sesi ini.
  final int lowballs;

  final List<NegotiationTurn> log;

  bool get isActive => status == NegotiationStatus.active;

  NegotiationSession copyWith({
    int? patience,
    int? anchor,
    NegotiationStatus? status,
    int? turns,
    NegotiationOffer? lastOffer,
    int? lowballs,
    List<NegotiationTurn>? log,
  }) => NegotiationSession(
    mode: mode,
    agent: agent,
    patience: patience ?? this.patience,
    anchor: anchor ?? this.anchor,
    limit: limit,
    preferredYears: preferredYears,
    agentTerms: agentTerms,
    status: status ?? this.status,
    turns: turns ?? this.turns,
    lastOffer: lastOffer ?? this.lastOffer,
    lowballs: lowballs ?? this.lowballs,
    log: log ?? this.log,
  );

  /// Bagian sesi yang disimpan sebagai JSON (selain kolom kunci tabel).
  String extrasJson() => jsonEncode({
    'py': preferredYears,
    'at': agentTerms.toJson(),
    'n': turns,
    'lo': lastOffer?.toJson(),
    'lb': lowballs,
    'log': [for (final t in log) t.toJson()],
  });

  static NegotiationSession fromStored({
    required NegotiationMode mode,
    required AgentProfile agent,
    required NegotiationStatus status,
    required int patience,
    required int anchor,
    required int limit,
    required String extras,
  }) {
    final j = jsonDecode(extras) as Map<String, dynamic>;
    final lo = j['lo'];
    return NegotiationSession(
      mode: mode,
      agent: agent,
      status: status,
      patience: patience,
      anchor: anchor,
      limit: limit,
      preferredYears: j['py'] as int? ?? 3,
      agentTerms: NegotiationOffer.fromJson(j['at'] as Map<String, dynamic>),
      turns: j['n'] as int? ?? 0,
      lastOffer:
          lo == null
              ? null
              : NegotiationOffer.fromJson(lo as Map<String, dynamic>),
      lowballs: j['lb'] as int? ?? 0,
      log: [
        for (final t in (j['log'] as List? ?? const []))
          NegotiationTurn.fromJson(t as Map<String, dynamic>),
      ],
    );
  }
}

enum AgentVerdict { accept, counter, walkOut }

/// Jawaban agen atas satu tawaran.
class AgentResponse {
  const AgentResponse({
    required this.verdict,
    required this.session,
    required this.message,
    required this.patienceDelta,
    required this.lowball,
    required this.agreedOffer,
  });

  final AgentVerdict verdict;

  /// Sesi setelah tawaran ini (riwayat sudah diperbarui).
  final NegotiationSession session;

  /// Komentar agen.
  final String message;
  final int patienceDelta;

  /// Tawaran ini dianggap menghina.
  final bool lowball;

  /// Paket yang disepakati (hanya bila [verdict] = accept).
  final NegotiationOffer? agreedOffer;
}

/// Nama-nama untuk kalimat agen.
class NegotiationNames {
  const NegotiationNames({required this.player, required this.club});

  /// Nama belakang pemain.
  final String player;

  /// Klub lawan: penjual (mode beli) atau pembeli (mode jual). Mode kontrak
  /// memakai klub kita.
  final String club;
}

/// Mesin tawar-menawar (README B.2–B.4).
abstract final class AgentNegotiator {
  /// Agen setuju bila tawaran memenuhi batas rahasia dan berjarak paling
  /// jauh 3% dari patokan terakhirnya.
  static const double acceptWithin = 0.03;

  /// Durasi kontrak yang disukai menurut usia (README B.2).
  static int preferredYears(int age) {
    if (age <= 23) return 5;
    if (age <= 27) return 4;
    if (age <= 30) return 3;
    return 2;
  }

  /// Keringanan gaji karena peran skuad (−5% s/d −10% untuk peran naik).
  static double roleBonus(SquadStatus s) => switch (s) {
    SquadStatus.keyPlayer => 0.10,
    SquadStatus.starter => 0.05,
    SquadStatus.rotation => 0,
    SquadStatus.backup => -0.05,
    SquadStatus.youth => -0.08,
  };

  /// Durasi yang tidak cocok mengurangi nilai paket di mata pemain.
  static double durationFactor(int years, int preferred) =>
      1 - 0.03 * (years - preferred).abs();

  static double _factor(
    NegotiationMode mode,
    NegotiationOffer o,
    int preferred,
  ) => switch (mode) {
    NegotiationMode.contract =>
      (1 + roleBonus(o.squadStatus)) *
          durationFactor(o.contractYears, preferred),
    _ => TransferRules.termsFactor(
      installmentYears: o.installmentYears,
      sellOnPct: o.sellOnPct,
    ),
  };

  /// Nilai paket di mata agen. Mode transfer: biaya × faktor cicilan &
  /// sell-on (sama dengan evaluasi bursa). Mode kontrak: gaji × faktor peran
  /// × kecocokan durasi.
  static int valueOf(NegotiationMode mode, NegotiationOffer o, int preferred) =>
      (o.amount * _factor(mode, o, preferred)).round();

  /// Kebalikan [valueOf]: nominal yang setara dengan [value] bila syarat
  /// lainnya seperti [terms]. Biaya dibulatkan ke €10 rb, gaji ke €5 rb.
  static int amountFor(
    NegotiationMode mode,
    int value,
    NegotiationOffer terms,
    int preferred,
  ) {
    final raw = value / _factor(mode, terms, preferred);
    final step = mode == NegotiationMode.contract ? 5 : 10;
    return ((raw / step).round() * step).clamp(step, 1 << 40).toInt();
  }

  /// Patokan agen dinyatakan dengan syarat [terms].
  static NegotiationOffer anchorOffer(
    NegotiationSession s, [
    NegotiationOffer? terms,
  ]) {
    final t = terms ?? s.agentTerms;
    return t.copyWith(amount: amountFor(s.mode, s.anchor, t, s.preferredYears));
  }

  /// Membuka sesi: agen mematok syarat awal dan menyampaikannya.
  static NegotiationSession open({
    required NegotiationMode mode,
    required AgentProfile agent,
    required int anchor,
    required int limit,
    required NegotiationOffer agentTerms,
    required NegotiationNames names,
    int preferredYears = 3,
    NegotiationOffer? userOpening,
    NegotiationSession? remembered,
  }) {
    final base = NegotiationSession(
      mode: mode,
      agent: agent,
      patience: 100,
      anchor: remembered?.anchor ?? anchor,
      limit: limit,
      preferredYears: preferredYears,
      agentTerms: agentTerms,
      lastOffer: remembered?.lastOffer ?? userOpening,
    );
    final opening = anchorOffer(base);
    final log = <NegotiationTurn>[
      if (remembered != null)
        NegotiationTurn.msg(
          byAgent: true,
          msg: Msg('agent.remembered', {'terms': describeMsg(mode, opening)}),
        ),
      if (remembered == null && userOpening != null)
        NegotiationTurn.msg(
          byAgent: false,
          msg: Msg('agent.userOpening', {
            'terms': describeMsg(mode, userOpening),
          }),
        ),
      NegotiationTurn.msg(
        byAgent: true,
        msg: _openingLine(mode, opening, names),
      ),
    ];
    return base.copyWith(log: log);
  }

  /// Mengevaluasi satu tawaran user (README B.3). Validasi dana dan skuad
  /// dilakukan pemanggil sebelum fungsi ini, agar tidak mengubah kesabaran.
  static AgentResponse respond(
    NegotiationSession s,
    NegotiationOffer offer,
    NegotiationNames names,
  ) {
    if (!s.isActive) throw StateError(tr('err.negotiationOver'));
    final mode = s.mode;
    final value = valueOf(mode, offer, s.preferredYears);
    final userLine = NegotiationTurn.msg(
      byAgent: false,
      msg: Msg('agent.userOffer', {'terms': describeMsg(mode, offer)}),
    );
    final turns = s.turns + 1;

    // Jarak ke patokan agen, positif = merugikan agen.
    final gap =
        mode.agentWantsMore
            ? (s.anchor - value) / s.anchor
            : (value - s.anchor) / s.anchor;
    final withinLimit =
        mode.agentWantsMore ? value >= s.limit : value <= s.limit;

    if (withinLimit && gap <= acceptWithin) {
      const msg = Msg('agent.accept');
      return AgentResponse(
        verdict: AgentVerdict.accept,
        session: s.copyWith(
          status: NegotiationStatus.agreed,
          turns: turns,
          lastOffer: offer,
          log: [
            ...s.log,
            userLine,
            NegotiationTurn.msg(byAgent: true, msg: msg),
          ],
        ),
        message: msg.resolve(),
        patienceDelta: 0,
        lowball: false,
        agreedOffer: offer,
      );
    }

    final lowball = gap > s.agent.lowballTolerance;
    final gapPenalty =
        gap <= 0.10
            ? 0
            : lowball
            ? s.agent.lowballPenalty
            : 10;
    final bonus = concessionBonus(mode, s.lastOffer, offer, s.preferredYears);
    final durationPenalty =
        mode == NegotiationMode.contract &&
                (offer.contractYears - s.preferredYears).abs() >= 2
            ? 5
            : 0;
    final delta = -s.agent.roundPenalty - gapPenalty - durationPenalty + bonus;
    final patience = (s.patience + delta).clamp(0, 100).toInt();

    if (patience <= 0) {
      const msg = Msg('agent.walkOut');
      return AgentResponse(
        verdict: AgentVerdict.walkOut,
        session: s.copyWith(
          status: NegotiationStatus.walkedOut,
          patience: 0,
          turns: turns,
          lastOffer: offer,
          lowballs: s.lowballs + (lowball ? 1 : 0),
          log: [
            ...s.log,
            userLine,
            NegotiationTurn.msg(byAgent: true, msg: msg),
          ],
        ),
        message: msg.resolve(),
        patienceDelta: delta,
        lowball: lowball,
        agreedOffer: null,
      );
    }

    // Kontra: agen bergerak mendekati tawaran user, tidak melewati batasnya.
    // Tawaran menghina tidak dibalas dengan potongan.
    var anchor = s.anchor;
    if (!lowball) {
      final target =
          mode.agentWantsMore
              ? (value > s.limit ? value : s.limit)
              : (value < s.limit ? value : s.limit);
      anchor = (s.anchor + (target - s.anchor) * s.agent.concession).round();
    }
    final next = s.copyWith(
      patience: patience,
      anchor: anchor,
      turns: turns,
      lastOffer: offer,
      lowballs: s.lowballs + (lowball ? 1 : 0),
    );
    // Kontra dinyatakan dengan syarat yang diajukan user.
    final counter = anchorOffer(next, offer);
    final msg = _counterLine(mode, offer, counter, patience, lowball, names);
    return AgentResponse(
      verdict: AgentVerdict.counter,
      session: next.copyWith(
        log: [...s.log, userLine, NegotiationTurn.msg(byAgent: true, msg: msg)],
      ),
      message: msg.resolve(),
      patienceDelta: delta,
      lowball: lowball,
      agreedOffer: null,
    );
  }

  /// Bonus konsesi (+5 per syarat yang membaik, maks +10) bila syarat
  /// non-nominal lebih baik bagi agen daripada tawaran user sebelumnya, dan
  /// tidak ada syarat yang memburuk.
  static int concessionBonus(
    NegotiationMode mode,
    NegotiationOffer? previous,
    NegotiationOffer offer,
    int preferred,
  ) {
    if (previous == null) return 0;
    final changes = <int>[];
    switch (mode) {
      case NegotiationMode.transferBuy:
        // Penjual suka dibayar langsung dan sell-on yang lebih besar.
        changes.add(
          previous.installmentYears.compareTo(offer.installmentYears),
        );
        changes.add(offer.sellOnPct.compareTo(previous.sellOnPct));
      case NegotiationMode.transferSell:
        // Pembeli suka dicicil dan sell-on yang lebih kecil.
        changes.add(
          offer.installmentYears.compareTo(previous.installmentYears),
        );
        changes.add(previous.sellOnPct.compareTo(offer.sellOnPct));
      case NegotiationMode.contract:
        changes.add(
          roleBonus(
            offer.squadStatus,
          ).compareTo(roleBonus(previous.squadStatus)),
        );
        changes.add(
          (previous.contractYears - preferred).abs().compareTo(
            (offer.contractYears - preferred).abs(),
          ),
        );
    }
    if (changes.any((c) => c < 0)) return 0;
    final better = changes.where((c) => c > 0).length;
    return (better * 5).clamp(0, 10).toInt();
  }

  /// Warna meter kesabaran: hijau ≥ 60, kuning 25–59, merah 1–24.
  static PatienceLevel levelOf(int patience) {
    if (patience >= 60) return PatienceLevel.open;
    if (patience >= 25) return PatienceLevel.impatient;
    if (patience > 0) return PatienceLevel.critical;
    return PatienceLevel.gone;
  }

  /// Teks satu paket, mis. "€12,5 jt dicicil 2 thn, sell-on 10%" atau
  /// "€450 rb/tahun selama 4 tahun sebagai Starter".
  static String describe(NegotiationMode mode, NegotiationOffer o) =>
      describeMsg(mode, o).resolve();

  /// [describe] sebagai `Msg`, untuk teks yang disimpan di riwayat.
  static Msg describeMsg(NegotiationMode mode, NegotiationOffer o) {
    if (mode == NegotiationMode.contract) {
      return Msg('agent.termsContract', {
        'wage': Msg.money(o.amount),
        'years': o.contractYears,
        'role': Msg('squadStatus.${o.squadStatus.name}'),
      });
    }
    final fee = Msg.money(o.amount);
    final head =
        o.installmentYears > 1
            ? Msg('agent.termsInstallments', {
              'fee': fee,
              'n': o.installmentYears,
            })
            : fee;
    return o.sellOnPct > 0
        ? Msg('agent.termsSellOn', {'head': head, 'pct': o.sellOnPct})
        : head;
  }

  static Msg _openingLine(
    NegotiationMode mode,
    NegotiationOffer o,
    NegotiationNames n,
  ) {
    final args = {
      'club': n.club,
      'player': n.player,
      'terms': describeMsg(mode, o),
    };
    return switch (mode) {
      NegotiationMode.transferBuy => Msg('agent.openBuy', args),
      NegotiationMode.transferSell => Msg('agent.openSell', args),
      NegotiationMode.contract => Msg('agent.openContract', args),
    };
  }

  static Msg _counterLine(
    NegotiationMode mode,
    NegotiationOffer offer,
    NegotiationOffer counter,
    int patience,
    bool lowball,
    NegotiationNames n,
  ) {
    final c = describeMsg(mode, counter);
    if (lowball) {
      return mode == NegotiationMode.transferSell
          ? Msg('agent.lowballSell', {
            'amount': Msg.money(offer.amount),
            'club': n.club,
          })
          : Msg('agent.lowball', {'amount': Msg.money(offer.amount)});
    }
    return switch (levelOf(patience)) {
      PatienceLevel.open =>
        mode == NegotiationMode.transferSell
            ? Msg('agent.counterSellOpen', {'club': n.club, 'terms': c})
            : Msg('agent.counterOpen', {'terms': c}),
      PatienceLevel.impatient => Msg('agent.counterImpatient', {'terms': c}),
      _ => Msg('agent.counterFinal', {'terms': c}),
    };
  }
}

enum PatienceLevel { open, impatient, critical, gone }
