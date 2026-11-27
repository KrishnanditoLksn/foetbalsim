/// Terjemahan aplikasi, murni Dart (tanpa Flutter) agar bisa dipakai di UI,
/// service, maupun engine pertandingan.
///
/// - Teks sesaat (label UI, pesan error, komentar laga): panggil [tr].
/// - Teks yang disimpan ke database (inbox, berita bursa, log negosiasi):
///   simpan `Msg(...).encode()`, lalu tampilkan dengan [trText]. Dengan begitu
///   teks lama ikut berganti bahasa saat bahasa aplikasi diganti.
///
/// Sintaks teks terjemahan:
/// - `{name}` diganti argumen `name`.
/// - `{n, plural, one{# hari} other{# hari}}` memilih bentuk tunggal/jamak
///   (`#` = angka). Aturan "one": en n == 1, fr n <= 1, id tidak pernah.
/// - `{n, ordinal}` = bilangan urutan: en "1st/2nd/3rd/4th", bahasa lain angka
///   saja (teks sekitarnya yang menambah akhiran, mis. fr "{n, ordinal}e").
library;

import 'dart:convert';

import 'app_language.dart';
import 'formatters.dart';
import 'strings/all.dart';

export 'app_language.dart';
export 'formatters.dart';

abstract final class L10n {
  /// Bahasa aktif. Diatur oleh `languageProvider` saat aplikasi berjalan.
  static AppLanguage current = AppLanguage.en;
}

/// Teks untuk [key] dalam bahasa aktif.
String tr(String key, [Map<String, Object?> args = const {}]) =>
    translate(L10n.current, key, args);

/// Teks tersimpan → teks tampil. Mendukung [Msg] yang di-encode dan teks
/// biasa dari save lama (dikembalikan apa adanya).
String trText(String? stored) {
  if (stored == null) return '';
  final msg = Msg.tryDecode(stored);
  return msg == null ? stored : msg.resolve();
}

/// Teks tersimpan → [Msg] agar bisa disisipkan ke [Msg] lain. Teks biasa
/// (save lama) dibungkus [Msg.raw].
Msg asMsg(String stored) => Msg.tryDecode(stored) ?? Msg.raw(stored);

/// Kunci + argumen terjemahan yang bisa disimpan dan diterjemahkan belakangan.
///
/// Nilai argumen: [String], [num], atau [Msg] bersarang (diterjemahkan dalam
/// bahasa yang sama). Kunci khusus:
/// - [Msg.money]: nominal uang (ribuan euro) diformat sesuai bahasa.
/// - [Msg.date]: tanggal diformat sesuai bahasa.
/// - [Msg.raw]: teks apa adanya (tidak diterjemahkan).
/// - [Msg.join]: gabungan beberapa [Msg] dengan pemisah.
class Msg {
  const Msg(this.key, [this.args = const {}]);

  Msg.money(int thousands) : this(_moneyKey, {'v': thousands});
  Msg.date(DateTime d) : this(_dateKey, {'v': d.millisecondsSinceEpoch});
  Msg.raw(String text) : this(_rawKey, {'v': text});
  Msg.join(List<Msg> parts, {String separator = ' '})
    : this(_joinKey, {
        's': separator,
        for (var i = 0; i < parts.length; i++) '$i': parts[i],
      });

  static const _moneyKey = '#money';
  static const _dateKey = '#date';
  static const _rawKey = '#raw';
  static const _joinKey = '#join';

  final String key;
  final Map<String, Object?> args;

  String resolve([AppLanguage? lang]) =>
      translate(lang ?? L10n.current, key, args);

  @override
  String toString() => resolve();

  Map<String, Object?> toJson() => {
    'k': key,
    if (args.isNotEmpty)
      'a': {
        for (final e in args.entries)
          e.key: e.value is Msg ? (e.value as Msg).toJson() : e.value,
      },
  };

  String encode() => jsonEncode(toJson());

  static Msg fromJson(Map<String, Object?> j) {
    final raw = (j['a'] as Map?)?.cast<String, Object?>() ?? const {};
    return Msg(j['k'] as String, {
      for (final e in raw.entries)
        e.key:
            e.value is Map
                ? fromJson((e.value as Map).cast<String, Object?>())
                : e.value,
    });
  }

  /// null bila [stored] bukan [Msg] yang di-encode (mis. teks save lama).
  static Msg? tryDecode(String stored) {
    if (!stored.startsWith('{"k":')) return null;
    try {
      return fromJson((jsonDecode(stored) as Map).cast<String, Object?>());
    } catch (_) {
      return null;
    }
  }
}

/// Teks [key] dalam [lang]. Kunci yang tidak dikenal dikembalikan apa adanya
/// (dan memicu assert saat debug) agar mudah ketahuan.
String translate(AppLanguage lang, String key, Map<String, Object?> args) {
  switch (key) {
    case Msg._moneyKey:
      return formatMoneyIn(lang, (args['v'] as num).toInt());
    case Msg._dateKey:
      return formatDateIn(
        lang,
        DateTime.fromMillisecondsSinceEpoch((args['v'] as num).toInt()),
      );
    case Msg._rawKey:
      return '${args['v']}';
    case Msg._joinKey:
      final parts = <String>[];
      for (var i = 0; args.containsKey('$i'); i++) {
        parts.add(_argText(lang, args['$i']));
      }
      return parts.where((p) => p.isNotEmpty).join('${args['s'] ?? ' '}');
  }
  final entry = allStrings[key];
  if (entry == null) {
    assert(false, 'Kunci terjemahan tidak dikenal: $key');
    return key;
  }
  final text = switch (lang) {
    AppLanguage.en => entry.en,
    AppLanguage.id => entry.id,
    AppLanguage.fr => entry.fr,
  };
  if (!text.contains('{')) return text;
  return _interpolate(lang, text, args);
}

final RegExp _pluralRe = RegExp(
  r'\{(\w+), plural, one\{([^{}]*)\} other\{([^{}]*)\}\}',
);
final RegExp _ordinalRe = RegExp(r'\{(\w+), ordinal\}');
final RegExp _argRe = RegExp(r'\{(\w+)\}');

String _ordinal(AppLanguage lang, num n) {
  if (lang != AppLanguage.en) return '$n';
  final i = n.toInt();
  final suffix =
      (i % 100 >= 11 && i % 100 <= 13)
          ? 'th'
          : switch (i % 10) {
            1 => 'st',
            2 => 'nd',
            3 => 'rd',
            _ => 'th',
          };
  return '$i$suffix';
}

String _interpolate(AppLanguage lang, String text, Map<String, Object?> args) {
  var out = text.replaceAllMapped(_pluralRe, (m) {
    final n = (args[m[1]] as num?) ?? 0;
    final one = switch (lang) {
      AppLanguage.en => n == 1,
      AppLanguage.fr => n.abs() < 2,
      AppLanguage.id => false,
    };
    return (one ? m[2]! : m[3]!).replaceAll('#', '$n');
  });
  out = out.replaceAllMapped(_ordinalRe, (m) {
    final v = args[m[1]];
    return v is num ? _ordinal(lang, v) : _argText(lang, v);
  });
  out = out.replaceAllMapped(_argRe, (m) {
    final name = m[1]!;
    return args.containsKey(name) ? _argText(lang, args[name]) : m[0]!;
  });
  return out;
}

String _argText(AppLanguage lang, Object? v) => switch (v) {
  null => '',
  Msg() => v.resolve(lang),
  _ => '$v',
};
