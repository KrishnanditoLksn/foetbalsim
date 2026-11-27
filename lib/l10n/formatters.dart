/// Format angka, uang, dan tanggal per bahasa. Murni Dart.
library;

import 'app_language.dart';
import 'l10n.dart' show L10n;

const Map<AppLanguage, List<String>> _monthsShort = {
  AppLanguage.en: [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ],
  AppLanguage.id: [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', //
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ],
  AppLanguage.fr: [
    'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', //
    'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
  ],
};

const Map<AppLanguage, List<String>> _monthsLong = {
  AppLanguage.en: [
    'January', 'February', 'March', 'April', 'May', 'June', //
    'July', 'August', 'September', 'October', 'November', 'December',
  ],
  AppLanguage.id: [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', //
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ],
  AppLanguage.fr: [
    'janvier', 'février', 'mars', 'avril', 'mai', 'juin', //
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
  ],
};

const Map<AppLanguage, List<String>> _weekdays = {
  AppLanguage.en: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
  AppLanguage.id: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
  AppLanguage.fr: ['lun.', 'mar.', 'mer.', 'jeu.', 'ven.', 'sam.', 'dim.'],
};

/// Nama bulan lengkap (1 = Januari) dalam bahasa aktif.
String monthName(int month) => _monthsLong[L10n.current]![month - 1];

/// Nama bulan singkat (1 = Jan) dalam bahasa aktif.
String monthShort(int month) => _monthsShort[L10n.current]![month - 1];

/// Nama hari singkat (1 = Senin, sama dengan `DateTime.weekday`).
String weekdayShort(int weekday) => _weekdays[L10n.current]![weekday - 1];

/// en "16 Aug 2025", id "16 Agu 2025", fr "16 août 2025".
String formatDateIn(AppLanguage lang, DateTime d) =>
    '${d.day} ${_monthsShort[lang]![d.month - 1]} ${d.year}';

/// Tanggal dalam bahasa aktif. Contoh: "16 Agu 2025".
String formatDate(DateTime d) => formatDateIn(L10n.current, d);

/// Tanggal dengan hari. Contoh: "Sab, 16 Agu 2025".
String formatDateWithDay(DateTime d) =>
    '${weekdayShort(d.weekday)}, ${formatDate(d)}';

/// Tanggal tanpa tahun. en "16 Aug", id "16 Agu".
String formatDayMonth(DateTime d) => '${d.day} ${monthShort(d.month)}';

/// Nilai uang disimpan dalam ribuan euro (€K).
/// en "€2.5M" / "€500K", id "€2,5 jt" / "€500 rb", fr "2,5 M€" / "500 k€".
String formatMoneyIn(AppLanguage lang, int thousands) {
  if (thousands.abs() >= 1000) {
    final millions = thousands / 1000;
    var n = millions.toStringAsFixed(millions.abs() >= 10 ? 0 : 1);
    if (lang != AppLanguage.en) n = n.replaceAll('.', ',');
    return switch (lang) {
      AppLanguage.en => '€${n}M',
      AppLanguage.id => '€$n jt',
      AppLanguage.fr => '$n M€',
    };
  }
  return switch (lang) {
    AppLanguage.en => '€${thousands}K',
    AppLanguage.id => '€$thousands rb',
    AppLanguage.fr => '$thousands k€',
  };
}

/// Nilai uang dalam bahasa aktif.
String formatMoney(int thousands) => formatMoneyIn(L10n.current, thousands);

/// Satuan ribuan euro untuk kolom input, mis. "€ rb" / "€K" / "k€".
String moneyUnitThousands() => switch (L10n.current) {
  AppLanguage.en => '€K',
  AppLanguage.id => '€ rb',
  AppLanguage.fr => 'k€',
};
