/// Mengubah teks Indonesia dari save lama (sebelum ada terjemahan) kembali
/// menjadi [Msg], dengan mencocokkan teks ke template bahasa Indonesia di
/// kamus. Template `id` diekstrak dari teks lama itu, sehingga polanya sama.
///
/// Contoh: "Transfer selesai: Mikel Dubois" →
/// `Msg('msg.completed.title', {'player': 'Mikel Dubois'})`.
library;

import 'l10n.dart';
import 'strings/all.dart';

abstract final class LegacyText {
  /// [Msg] untuk [text] yang cocok dengan template berkunci [prefix], atau
  /// null bila tidak ada yang cocok (teks dibiarkan apa adanya).
  static Msg? match(String text, {String prefix = 'msg.'}) {
    for (final t in _templates) {
      if (!t.key.startsWith(prefix)) continue;
      final m = t.re.firstMatch(text.trim());
      if (m == null) continue;
      final values = {for (final name in t.args) name: m.namedGroup(name)!};
      // Argumen uang harus benar-benar nominal; kalau tidak, template ini
      // hanya kebetulan cocok (argumen menelan sisa kalimat).
      if (!values.entries.every((e) => _plausible(e.key, e.value))) continue;
      return Msg(t.key, {
        for (final e in values.entries)
          if (!t.dropped.contains(e.key)) e.key: _arg(e.key, e.value, t.key),
      });
    }
    return null;
  }

  /// Nominal uang yang diformat bahasa Indonesia (format lama memakai titik
  /// desimal): "€373 rb", "€1.2 jt", "€1,2 jt" → ribuan euro.
  static int? parseMoney(String s) {
    final m = RegExp(r'^€\s?(-?[\d.,]+)\s?(rb|jt)$').firstMatch(s.trim());
    if (m == null) return null;
    final n = double.tryParse(m[1]!.replaceAll(',', '.'));
    if (n == null) return null;
    return (m[2] == 'jt' ? n * 1000 : n).round();
  }

  /// "€12 jt (cicilan 3 thn, sell-on 20%)" → biaya, cicilan, sell-on.
  static ({int fee, int installmentYears, int sellOnPct})? parseTerms(
    String s,
  ) {
    final m = RegExp(r'^(€[^()]+?)(?:\s\((.+)\))?$').firstMatch(s.trim());
    if (m == null) return null;
    final fee = parseMoney(m[1]!);
    if (fee == null) return null;
    final extras = m[2] ?? '';
    final inst = RegExp(r'cicilan (\d+) thn').firstMatch(extras);
    final sellOn = RegExp(r'sell-on (\d+)%').firstMatch(extras);
    return (
      fee: fee,
      installmentYears: inst == null ? 1 : int.parse(inst[1]!),
      sellOnPct: sellOn == null ? 0 : int.parse(sellOn[1]!),
    );
  }

  static bool _plausible(String name, String value) => switch (name) {
    'terms' => parseTerms(value) != null,
    'fee' || 'wage' || 'expected' || 'amount' => parseMoney(value) != null,
    // Nama pemain/klub: pendek, tanpa akhir kalimat atau nominal.
    'player' ||
    'club' ||
    'from' ||
    'to' => !value.contains(RegExp(r'[.€]')) && value.split(' ').length <= 5,
    _ => true,
  };

  static Object _arg(String name, String value, String parentKey) {
    if (RegExp(r'^-?\d+$').hasMatch(value)) return int.parse(value);
    final money = parseMoney(value);
    if (money != null) return Msg.money(money);
    if (name == 'terms') {
      final t = parseTerms(value);
      if (t != null) {
        final extras = [
          if (t.installmentYears > 1)
            Msg('terms.installments', {'n': t.installmentYears}),
          if (t.sellOnPct > 0) Msg('terms.sellOn', {'pct': t.sellOnPct}),
        ];
        return extras.isEmpty
            ? Msg.money(t.fee)
            : Msg('terms.withExtras', {
              'fee': Msg.money(t.fee),
              'extras': Msg.join(extras, separator: ', '),
            });
      }
    }
    // Kata tetap dari kelompok kunci yang sama, mis. "naik" di hasil laga
    // → msg.result.moraleUp.
    final group = parentKey.substring(0, parentKey.lastIndexOf('.') + 1);
    for (final e in allStrings.entries) {
      if (e.key.startsWith(group) &&
          !e.value.id.contains('{') &&
          e.value.id == value) {
        return Msg(e.key);
      }
    }
    // Kalimat bersarang (mis. isi berita bursa, alasan penolakan).
    if (value.contains(' ')) {
      for (final prefix in const ['news.', 'reason.', 'msg.']) {
        final nested = match(value, prefix: prefix);
        if (nested != null) return nested;
      }
    }
    return value;
  }

  /// Template berurutan dari teks tetap terpanjang, agar template umum
  /// (mis. "{text}") tidak menang atas template yang lebih spesifik.
  static final List<_Template> _templates = () {
    final list = <_Template>[
      for (final (key, template, dropped) in _oldTemplates)
        if (_Template.tryBuild(key, template, dropped: dropped) case final t?)
          t,
    ];
    for (final e in allStrings.entries) {
      if (!const ['msg.', 'news.', 'reason.'].any(e.key.startsWith)) continue;
      final t = _Template.tryBuild(e.key, e.value.id);
      if (t != null) list.add(t);
    }
    list.sort((a, b) => b.literalLength.compareTo(a.literalLength));
    return list;
  }();
}

/// Kalimat Indonesia versi lama yang sudah diganti di kamus:
/// (kunci sekarang, template lama, argumen lama yang tidak dipakai lagi).
const _oldTemplates = <(String, String, Set<String>)>[
  (
    'msg.feeAgreed.body',
    '{lead} {player} mengharapkan gaji minimal {wage}/tahun. '
        'Ajukan kontrak untuk menyelesaikan transfer.',
    {'wage'},
  ),
];

class _Template {
  _Template(
    this.key,
    this.re,
    this.args,
    this.literalLength, [
    this.dropped = const {},
  ]);

  final String key;
  final RegExp re;
  final List<String> args;
  final int literalLength;

  /// Argumen template lama yang tidak ada di teks sekarang.
  final Set<String> dropped;

  static final _plural = RegExp(
    r'\{(\w+), plural, one\{([^{}]*)\} other\{([^{}]*)\}\}',
  );
  static final _token = RegExp(r'\{(\w+)\}|\u0000(\w+)\u0000');

  static _Template? tryBuild(
    String key,
    String template, {
    Set<String> dropped = const {},
  }) {
    // Bahasa Indonesia selalu memakai bentuk "other"; '#' = angkanya.
    final flat = template.replaceAllMapped(
      _plural,
      (m) => m[3]!.replaceAll('#', '\u0000${m[1]}\u0000'),
    );
    final args = <String>[];
    final buf = StringBuffer('^');
    var literal = 0;
    var last = 0;
    for (final m in _token.allMatches(flat)) {
      final text = flat.substring(last, m.start);
      literal += text.trim().length;
      buf.write(RegExp.escape(text));
      final name = m[1] ?? m[2]!;
      final number = m[2] != null;
      if (args.contains(name)) {
        buf.write('\\k<$name>');
      } else {
        args.add(name);
        buf.write(
          number
              ? '(?<$name>-?\\d+)'
              // Nama pemain/klub tidak memuat titik atau nominal.
              : const {'player', 'club', 'from', 'to'}.contains(name)
              ? '(?<$name>[^.€]+?)'
              : '(?<$name>.+?)',
        );
      }
      last = m.end;
    }
    final tail = flat.substring(last);
    literal += tail.trim().length;
    buf
      ..write(RegExp.escape(tail))
      ..write(r'$');
    // Template tanpa teks tetap (mis. "{fee} ({extras})") terlalu umum.
    if (literal < 4) return null;
    return _Template(
      key,
      RegExp(buf.toString(), dotAll: true),
      args,
      literal,
      dropped,
    );
  }
}
