import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/game_actions.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/utils/format_utils.dart';
import '../../core/widgets/futbol_ui.dart';
import '../../data/services/transfer_service.dart';
import '../../domain/enums/squad_status.dart';
import '../../domain/finance/money_label.dart';
import '../../domain/transfer/agent_negotiator.dart';
import '../../domain/transfer/transfer_rules.dart';

/// Ruang Negosiasi (README_NEGOTIATION_ROOM C): tawar-menawar langsung
/// dengan agen pemain untuk biaya transfer atau kontrak.
///
/// Keluar dari layar ini tidak membatalkan apa pun: sesi tersimpan dan
/// dilanjutkan saat ruangan dibuka lagi.
class NegotiationRoomScreen extends ConsumerStatefulWidget {
  const NegotiationRoomScreen({super.key, required this.offerId});

  final int offerId;

  @override
  ConsumerState<NegotiationRoomScreen> createState() =>
      _NegotiationRoomScreenState();
}

class _NegotiationRoomScreenState extends ConsumerState<NegotiationRoomScreen> {
  final _amount = TextEditingController();
  NegotiationRoom? _room;
  NegotiationOffer? _draft;
  NegotiationStep? _outcome;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final room = await GameActions.call(
        ref,
        (e) => e.openNegotiation(widget.offerId),
      );
      if (!mounted) return;
      final s = room.session;
      final draft = s.lastOffer ?? AgentNegotiator.anchorOffer(s);
      setState(() {
        _room = room;
        _outcome = null;
        _error = null;
        _setDraft(draft);
      });
    } on StateError catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  void _setDraft(NegotiationOffer d) {
    _draft = d;
    final text = '${d.amount}';
    if (_amount.text != text) {
      _amount.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  void _update(NegotiationOffer d) => setState(() => _setDraft(d));

  /// Langkah nominal: biaya €10 rb, gaji €5 rb.
  int get _step => _room?.mode == NegotiationMode.contract ? 5 : 10;

  void _nudge(double pct) {
    final d = _draft!;
    final raw = d.amount * (1 + pct);
    final next = ((raw / _step).round() * _step).clamp(_step, 1 << 40).toInt();
    _update(d.copyWith(amount: next));
  }

  /// Masalah dana yang membuat tawaran tidak bisa diajukan (null = aman).
  String? _fundsProblem(NegotiationRoom room, NegotiationOffer d) {
    if (d.amount <= 0) return 'Isi nominal lebih dari nol.';
    if (room.mode != NegotiationMode.transferBuy) return null;
    if (d.amount > room.transferBudget) {
      return 'Melebihi anggaran transfer (${moneyLabel(room.transferBudget)}).';
    }
    final upfront = TransferRules.upfront(d.amount, d.installmentYears);
    if (upfront > room.balance) {
      return 'Pembayaran di muka ${moneyLabel(upfront)} melebihi saldo '
          '(${moneyLabel(room.balance)}).';
    }
    return null;
  }

  Future<void> _act(Future<NegotiationStep> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.maybeOf(context);
    try {
      final step = await action();
      if (!mounted) return;
      setState(() {
        _room = _room!.withSession(step.response.session);
        if (step.finished) _outcome = step;
        final last = step.response.session.lastOffer;
        if (!step.finished && last != null) _setDraft(last);
      });
      if (step.summary != null) {
        messenger?.showSnackBar(SnackBar(content: Text(step.summary!)));
      }
    } on StateError catch (e) {
      messenger?.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _submit() => _act(
    () => GameActions.call(ref, (e) => e.negotiate(widget.offerId, _draft!)),
  );

  void _acceptAnchor() => _act(
    () => GameActions.call(
      ref,
      (e) => e.acceptAgentTerms(widget.offerId, _draft!),
    ),
  );

  Future<void> _endTalks() async {
    final room = _room!;
    final selling = room.mode == NegotiationMode.transferSell;
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(selling ? 'Tolak tawaran?' : 'Batalkan negosiasi?'),
            content: Text(
              selling
                  ? '${room.counterpartName} akan mundur dan '
                      '${room.player.fullName} tetap di klub Anda.'
                  : 'Negosiasi untuk ${room.player.fullName} ditutup. Anda '
                      'bisa menawar lagi nanti.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Lanjut berunding'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(selling ? 'Tolak tawaran' : 'Batalkan negosiasi'),
              ),
            ],
          ),
    );
    if (ok != true || !mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final navigator = Navigator.of(context);
    try {
      await GameActions.run(
        ref,
        (e) => e.respondToOffer(widget.offerId, selling ? 'reject' : 'cancel'),
      );
      messenger?.showSnackBar(
        SnackBar(
          content: Text(selling ? 'Tawaran ditolak.' : 'Negosiasi dibatalkan.'),
        ),
      );
      navigator.pop();
    } on StateError catch (e) {
      messenger?.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final room = _room;
    final accent = AppTheme.accentFor(ref.watch(ourClubProvider));
    final canEnd = room != null && _outcome == null && room.session.isActive;
    // Ponsel lanskap: app bar lebih tipis agar isi mendapat ruang.
    final short = MediaQuery.sizeOf(context).height < 480;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: short ? 46 : null,
        title: const Text('Ruang negosiasi'),
        actions: [
          if (canEnd)
            TextButton(
              onPressed: _busy ? null : _endTalks,
              child: Text(
                room.mode == NegotiationMode.transferSell
                    ? 'Tolak'
                    : 'Batalkan',
                style: const TextStyle(color: Chalk.red),
              ),
            ),
        ],
      ),
      body:
          _error != null
              ? _Message(text: _error!, onBack: () => Navigator.pop(context))
              : room == null
              ? const Center(child: CircularProgressIndicator())
              : _body(room, accent),
      // Hasil akhir menggantikan tombol tawar di bawah, supaya langsung
      // terlihat tanpa menggulir.
      bottomNavigationBar:
          room == null || _error != null
              ? null
              : _outcome != null
              ? _Outcome(
                step: _outcome!,
                onContinue: _load,
                onBack: () => Navigator.pop(context),
              )
              : _actionBar(room, accent),
    );
  }

  Widget _actionBar(NegotiationRoom room, Color accent) {
    final anchor = AgentNegotiator.anchorOffer(room.session, _draft);
    return _ActionBar(
      busy: _busy,
      canSubmit: _fundsProblem(room, _draft!) == null,
      canAccept: _fundsProblem(room, anchor) == null,
      acceptLabel: 'Terima ${moneyLabel(anchor.amount)}',
      onSubmit: _submit,
      onAccept: _acceptAnchor,
    );
  }

  /// Tata letak menurut ukuran layar:
  /// - lebar ≥ 720 dp (tablet, ponsel lanskap): dua kolom, kiri pemain &
  ///   agen & riwayat, kanan angka & kontrol tawaran;
  /// - selain itu satu kolom, maksimal 640 dp di tengah;
  /// - tinggi < 700 dp (mis. OPPO A57 360×640): header pemain dan panel agen
  ///   diringkas agar kontrol tawaran cepat terlihat.
  Widget _body(NegotiationRoom room, Color accent) {
    return LayoutBuilder(
      builder: (context, box) {
        final size = MediaQuery.sizeOf(context);
        // Teks sistem yang diperbesar memakan tinggi seperti layar pendek.
        final scale = MediaQuery.textScalerOf(context).scale(1);
        final compact = size.height / scale < 700;
        final wide = box.maxWidth >= 720;
        final s = room.session;
        final side = box.maxWidth < 360 ? 16.0 : 20.0;

        final identity = <Widget>[
          _PlayerLine(room: room, compact: compact),
          SizedBox(height: compact ? 14 : 22),
          _AgentBoard(session: s, accent: accent, compact: compact),
        ];
        final history = <Widget>[
          SectionHeader('Riwayat (${s.log.length})'),
          _History(log: s.log, agentName: room.agent.name, accent: accent),
        ];
        final controls = _controls(room, accent, compact: compact);

        if (wide) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(side, 4, 12, 24),
                      children: [...identity, ...history],
                    ),
                  ),
                  const VerticalDivider(width: 1, color: Chalk.line),
                  Expanded(
                    flex: 6,
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(16, 8, side, 24),
                      children: controls,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: EdgeInsets.fromLTRB(side, 4, side, 24),
              children: [
                ...identity,
                SizedBox(height: compact ? 14 : 20),
                ...controls,
                ...history,
              ],
            ),
          ),
        );
      },
    );
  }

  /// Angka utama dan kontrol tawaran.
  List<Widget> _controls(
    NegotiationRoom room,
    Color accent, {
    required bool compact,
  }) {
    final s = room.session;
    final draft = _draft!;
    final anchor = AgentNegotiator.anchorOffer(s, draft);
    final problem = _fundsProblem(room, draft);
    return [
      StatStrip(
        children: [
          StatFigure(
            label: _anchorLabel(room.mode),
            value: moneyLabel(anchor.amount),
            color: accent,
            labelLines: 2,
          ),
          StatFigure(
            label: 'Tawaran Anda',
            value: moneyLabel(draft.amount),
            labelLines: 2,
          ),
          switch (room.mode) {
            NegotiationMode.transferBuy => StatFigure(
              label: 'Anggaran',
              value: moneyLabel(room.transferBudget),
              labelLines: 2,
            ),
            NegotiationMode.transferSell => StatFigure(
              label: 'Nilai pasar',
              value: moneyLabel(room.player.marketValue),
              labelLines: 2,
            ),
            NegotiationMode.contract => StatFigure(
              label: 'Durasi disukai',
              value: '${s.preferredYears} thn',
              labelLines: 2,
            ),
          },
        ],
      ),
      if (_outcome == null) ...[
        SectionHeader(
          'Tawaran Anda',
          padding: EdgeInsets.fromLTRB(0, compact ? 16 : 22, 0, 6),
        ),
        _OfferEditor(
          mode: room.mode,
          draft: draft,
          preferredYears: s.preferredYears,
          controller: _amount,
          onAmountTyped:
              (v) => setState(() => _draft = draft.copyWith(amount: v)),
          onNudge: _nudge,
          onChanged: _update,
        ),
        if (problem != null) ...[
          const SizedBox(height: 10),
          Text(
            problem,
            style: const TextStyle(
              color: Chalk.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 10),
        Text(
          _tradeOffHint(room.mode),
          style: const TextStyle(color: Chalk.dim, fontSize: 13, height: 1.35),
        ),
      ],
    ];
  }

  static String _anchorLabel(NegotiationMode m) => switch (m) {
    NegotiationMode.transferSell => 'Tawaran pembeli',
    NegotiationMode.contract => 'Gaji diminta agen',
    NegotiationMode.transferBuy => 'Patokan agen',
  };

  static String _tradeOffHint(NegotiationMode m) => switch (m) {
    NegotiationMode.transferBuy =>
      'Pembayaran langsung dan sell-on yang lebih besar membuat agen mau '
          'menurunkan harga. Patokan di atas sudah menyesuaikan syarat Anda.',
    NegotiationMode.transferSell =>
      'Menerima cicilan membuat pembeli mau membayar nominal lebih tinggi; '
          'meminta sell-on membuatnya menurunkan nominal.',
    NegotiationMode.contract =>
      'Peran yang lebih besar dan durasi yang cocok dengan usia pemain '
          'membuat agen mau menurunkan gaji.',
  };
}

// --- Bagian layar --------------------------------------------------------------

/// Identitas pemain: garis warna klub di kiri, nama besar, lalu posisi,
/// usia, CA, dan apa yang sedang dirundingkan.
class _PlayerLine extends ConsumerWidget {
  const _PlayerLine({required this.room, this.compact = false});

  final NegotiationRoom room;

  /// Layar pendek: nama satu baris, info lain diringkas.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = room.player;
    final club = ref.watch(clubByIdProvider(p.clubId)).valueOrNull;
    final stripe = club == null ? Chalk.line : colorFromHex(club.primaryColor);
    final subject = switch (room.mode) {
      NegotiationMode.transferBuy =>
        'Harga transfer dari ${room.counterpartName}',
      NegotiationMode.transferSell =>
        'Tawaran ${room.counterpartName} untuk pemain Anda',
      NegotiationMode.contract =>
        'Kontrak pemain, harga ${moneyLabel(room.offer.fee)} sudah disepakati',
    };
    if (compact) {
      return Container(
        padding: const EdgeInsets.only(left: 12),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: stripe, width: 4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${p.firstName} ',
                          style: const TextStyle(
                            color: Chalk.dim,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(text: p.lastName),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: Fonts.condensed,
                      fontSize: 24,
                      height: 1.1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PositionBadge(p.position),
              ],
            ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${p.age} tahun, '),
                  TextSpan(
                    text: 'CA ${p.currentAbility}',
                    style: TextStyle(color: ratingColor(p.currentAbility)),
                  ),
                  TextSpan(text: '. $subject'),
                ],
              ),
              style: const TextStyle(color: Chalk.dim, fontSize: 13),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.only(left: 14),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: stripe, width: 5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            p.firstName,
            style: const TextStyle(color: Chalk.dim, fontSize: 15),
          ),
          Text(
            p.lastName,
            style: const TextStyle(
              fontFamily: Fonts.condensed,
              fontSize: 36,
              height: 1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              PositionBadge(p.position),
              Text('${p.age} tahun'),
              Text(
                'CA ${p.currentAbility}',
                style: TextStyle(color: ratingColor(p.currentAbility)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(subject, style: const TextStyle(color: Chalk.dim)),
        ],
      ),
    );
  }
}

/// Elemen utama layar: agen, sisa kesabarannya sebagai coretan kapur, dan
/// kalimat terakhirnya ditulis besar di papan.
class _AgentBoard extends StatelessWidget {
  const _AgentBoard({
    required this.session,
    required this.accent,
    this.compact = false,
  });

  final NegotiationSession session;
  final Color accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final agent = session.agent;
    final lastLine =
        session.log
            .lastWhere(
              (t) => t.byAgent,
              orElse: () => const NegotiationTurn(byAgent: true, text: ''),
            )
            .text;
    final level = AgentNegotiator.levelOf(session.patience);
    final mood = switch (level) {
      PatienceLevel.open => 'masih terbuka berdiskusi',
      PatienceLevel.impatient => 'mulai tidak sabar',
      PatienceLevel.critical => 'satu langkah salah, ia pergi',
      PatienceLevel.gone => 'sudah pergi',
    };
    final style = 'gaya ${agent.style.label.toLowerCase()}';
    return Container(
      padding:
          compact
              ? const EdgeInsets.fromLTRB(14, 12, 14, 14)
              : const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: Chalk.boardDeep,
        borderRadius: BorderRadius.circular(4),
        border: Border(top: BorderSide(color: accent, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (compact)
            // Nama dan gaya satu baris supaya panel tetap pendek.
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: agent.name),
                  TextSpan(
                    text: '  agen, $style',
                    style: const TextStyle(
                      fontFamily: Fonts.body,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Chalk.dim,
                    ),
                  ),
                ],
              ),
              style: const TextStyle(
                fontFamily: Fonts.condensed,
                fontSize: 19,
                fontWeight: FontWeight.w600,
              ),
            )
          else ...[
            Text(
              agent.name,
              style: const TextStyle(
                fontFamily: Fonts.condensed,
                fontSize: 22,
                fontWeight: FontWeight.w600,
                height: 1.1,
              ),
            ),
            Text(
              'Agen pemain, $style',
              style: const TextStyle(color: Chalk.dim, fontSize: 13),
            ),
          ],
          SizedBox(height: compact ? 10 : 14),
          _PatienceTally(patience: session.patience, height: compact ? 18 : 26),
          const SizedBox(height: 6),
          Text(
            'Kesabaran ${session.patience}%, $mood',
            style: TextStyle(
              color: _levelColor(level),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: compact ? 10 : 16),
          Text(
            '“$lastLine”',
            style: TextStyle(
              fontSize: compact ? 16 : 19,
              height: compact ? 1.35 : 1.4,
              color: Chalk.white,
            ),
          ),
        ],
      ),
    );
  }
}

Color _levelColor(PatienceLevel l) => switch (l) {
  PatienceLevel.open => Chalk.green,
  PatienceLevel.impatient => Chalk.yellow,
  PatienceLevel.critical || PatienceLevel.gone => Chalk.red,
};

/// Kesabaran sebagai turus kapur: 20 coretan (5% per coretan) dalam empat
/// ikat. Coretan yang hilang memudar saat agen kehilangan kesabaran.
class _PatienceTally extends StatelessWidget {
  const _PatienceTally({required this.patience, this.height = 26});

  final int patience;
  final double height;

  @override
  Widget build(BuildContext context) {
    final lit = (patience / 5).ceil();
    final color = _levelColor(AgentNegotiator.levelOf(patience));
    final still = MediaQuery.of(context).disableAnimations;
    return Semantics(
      label: 'Kesabaran agen $patience persen',
      excludeSemantics: true,
      child: Row(
        children: [
          for (var g = 0; g < 4; g++) ...[
            if (g > 0) const SizedBox(width: 12),
            for (var i = 0; i < 5; i++) ...[
              if (i > 0) const SizedBox(width: 5),
              AnimatedContainer(
                duration:
                    still ? Duration.zero : const Duration(milliseconds: 450),
                curve: Curves.easeOut,
                width: 4,
                height: height,
                transform: Matrix4.rotationZ(((g * 5 + i) % 3 - 1) * 0.04),
                decoration: BoxDecoration(
                  color: g * 5 + i < lit ? color : Chalk.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// Kontrol tawaran: nominal dengan tombol cepat, lalu syarat sesuai mode.
class _OfferEditor extends StatelessWidget {
  const _OfferEditor({
    required this.mode,
    required this.draft,
    required this.preferredYears,
    required this.controller,
    required this.onAmountTyped,
    required this.onNudge,
    required this.onChanged,
  });

  final NegotiationMode mode;
  final NegotiationOffer draft;
  final int preferredYears;
  final TextEditingController controller;
  final ValueChanged<int> onAmountTyped;
  final ValueChanged<double> onNudge;
  final ValueChanged<NegotiationOffer> onChanged;

  @override
  Widget build(BuildContext context) {
    final contract = mode == NegotiationMode.contract;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: scoreStyle(size: 26),
          decoration: InputDecoration(
            labelText:
                contract
                    ? 'Gaji per tahun (€ ribu)'
                    : 'Biaya transfer (€ ribu)',
            suffixText: moneyLabel(draft.amount),
          ),
          onChanged: (t) => onAmountTyped(int.tryParse(t) ?? 0),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final pct in const [-0.10, -0.05, 0.05, 0.10]) ...[
              if (pct != -0.10) const SizedBox(width: 6),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 40),
                  ),
                  onPressed: () => onNudge(pct),
                  child: Text(
                    '${pct > 0 ? '+' : '−'}${(pct.abs() * 100).round()}%',
                    style: scoreStyle(size: 16, weight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (!contract) ...[
          const _Label('Pembayaran'),
          _Choices<int>(
            values: TransferRules.installmentOptions,
            selected: draft.installmentYears,
            label: (v) => v == 1 ? 'Langsung' : 'Cicil $v tahun',
            onSelected: (v) => onChanged(draft.copyWith(installmentYears: v)),
          ),
          const _Label('Sell-on penjualan berikutnya'),
          _Choices<int>(
            values: TransferRules.sellOnOptions,
            selected: draft.sellOnPct,
            label: (v) => v == 0 ? 'Tanpa' : '$v%',
            onSelected: (v) => onChanged(draft.copyWith(sellOnPct: v)),
          ),
        ] else ...[
          const _Label('Durasi kontrak'),
          _Choices<int>(
            values: const [1, 2, 3, 4, 5],
            selected: draft.contractYears,
            label:
                (v) => v == preferredYears ? '$v tahun (disukai)' : '$v tahun',
            onSelected: (v) => onChanged(draft.copyWith(contractYears: v)),
          ),
          const _Label('Peran di skuad'),
          _Choices<SquadStatus>(
            values: const [
              SquadStatus.keyPlayer,
              SquadStatus.starter,
              SquadStatus.rotation,
              SquadStatus.backup,
            ],
            selected: draft.squadStatus,
            label: (v) => v.label,
            onSelected: (v) => onChanged(draft.copyWith(squadStatus: v)),
          ),
        ],
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 6),
    child: Text(text, style: const TextStyle(color: Chalk.dim, fontSize: 14)),
  );
}

class _Choices<T> extends StatelessWidget {
  const _Choices({
    required this.values,
    required this.selected,
    required this.label,
    required this.onSelected,
  });

  final List<T> values;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 6,
    runSpacing: 6,
    children: [
      for (final v in values)
        ChoiceChip(
          label: Text(label(v)),
          selected: v == selected,
          showCheckmark: false,
          onSelected: (_) => onSelected(v),
        ),
    ],
  );
}

/// Riwayat tawar-menawar, terbaru di bawah. Hanya empat baris terakhir yang
/// tampil sampai diminta semua.
class _History extends StatefulWidget {
  const _History({
    required this.log,
    required this.agentName,
    required this.accent,
  });

  final List<NegotiationTurn> log;
  final String agentName;
  final Color accent;

  @override
  State<_History> createState() => _HistoryState();
}

class _HistoryState extends State<_History> {
  bool _all = false;

  @override
  Widget build(BuildContext context) {
    final log = widget.log;
    final shown = _all || log.length <= 4 ? log : log.sublist(log.length - 4);
    final first = widget.agentName.split(' ').first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (shown.length < log.length)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => setState(() => _all = true),
              child: Text(
                'Tampilkan ${log.length - shown.length} baris sebelumnya',
              ),
            ),
          ),
        for (final t in shown)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Chalk.line)),
            ),
            // Nama pembicara sebaris dengan kalimatnya, supaya tidak butuh
            // kolom lebar tetap di layar sempit atau teks besar.
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: t.byAgent ? '$first  ' : 'Anda  ',
                    style: TextStyle(
                      color: t.byAgent ? widget.accent : Chalk.dim,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: t.text),
                ],
              ),
              style: TextStyle(
                color: t.byAgent ? Chalk.white : Chalk.dim,
                height: 1.35,
              ),
            ),
          ),
      ],
    );
  }
}

/// Hasil akhir sesi di bagian bawah layar: sepakat atau walk-out.
class _Outcome extends StatelessWidget {
  const _Outcome({
    required this.step,
    required this.onContinue,
    required this.onBack,
  });

  final NegotiationStep step;
  final VoidCallback onContinue;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final agreed = step.verdict == AgentVerdict.accept;
    final selling = step.response.session.mode == NegotiationMode.transferSell;
    final note =
        agreed
            ? step.summary
            : selling
            ? 'Pembeli mundur. Pemain tetap di klub Anda.'
            : 'Pemain ini baru bisa ditawar lagi seminggu lagi. Agennya akan '
                'mengingat angka terakhir.';
    final color = agreed ? Chalk.green : Chalk.red;
    final short = MediaQuery.sizeOf(context).height < 480;
    return _BottomPanel(
      color: Chalk.boardDeep,
      border: BorderSide(color: color, width: 3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: agreed ? 'Sepakat' : 'Agen pergi',
                  style: TextStyle(
                    fontFamily: Fonts.condensed,
                    fontSize: short ? 22 : 28,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                // Di layar pendek keterangan ikut di baris judul.
                if (note != null && short) TextSpan(text: '  $note'),
              ],
            ),
            style: const TextStyle(color: Chalk.dim),
          ),
          if (note != null && !short)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(note, style: const TextStyle(color: Chalk.dim)),
            ),
          SizedBox(height: short ? 6 : 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onBack,
                  child: const FittedBox(child: Text('Kembali')),
                ),
              ),
              if (step.continuesToContract) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: onContinue,
                    child: const FittedBox(child: Text('Lanjut ke kontrak')),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Tombol bawah: ajukan tawaran sendiri atau terima patokan agen.
class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.busy,
    required this.canSubmit,
    required this.canAccept,
    required this.acceptLabel,
    required this.onSubmit,
    required this.onAccept,
  });

  final bool busy;
  final bool canSubmit;
  final bool canAccept;
  final String acceptLabel;
  final VoidCallback onSubmit;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    return _BottomPanel(
      color: Chalk.board,
      border: const BorderSide(color: Chalk.line),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: busy || !canSubmit ? null : onSubmit,
              child: const FittedBox(child: Text('Ajukan tawaran')),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FilledButton(
              onPressed: busy || !canAccept ? null : onAccept,
              child: FittedBox(child: Text(acceptLabel)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Wadah bar bawah: di atas area navigasi sistem, lebih tipis di layar
/// pendek (mis. lanskap), dan tidak melebar lebih dari 640 dp di tablet.
class _BottomPanel extends StatelessWidget {
  const _BottomPanel({
    required this.child,
    required this.color,
    required this.border,
  });

  final Widget child;
  final Color color;
  final BorderSide border;

  @override
  Widget build(BuildContext context) {
    final short = MediaQuery.sizeOf(context).height < 480;
    return Container(
      decoration: BoxDecoration(color: color, border: Border(top: border)),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                short ? 6 : 10,
                16,
                short ? 6 : 10,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, required this.onBack});

  final String text;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onBack, child: const Text('Kembali')),
        ],
      ),
    ),
  );
}
