/// Format teks murni (tanpa Flutter) agar bisa dipakai di service/engine.
library;

const List<String> _monthsShort = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

const List<String> monthNames = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

const List<String> _weekdays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

/// Contoh: "16 Agu 2025".
String formatDate(DateTime d) => '${d.day} ${_monthsShort[d.month - 1]} ${d.year}';

/// Contoh: "Sab, 16 Agu 2025".
String formatDateWithDay(DateTime d) =>
    '${_weekdays[d.weekday - 1]}, ${formatDate(d)}';

/// Nilai uang disimpan dalam ribuan euro (€K). Contoh: 25000 → "€25 jt".
String formatMoney(int thousands) {
  if (thousands.abs() >= 1000) {
    final millions = thousands / 1000;
    return '€${millions.toStringAsFixed(millions.abs() >= 10 ? 0 : 1)} jt';
  }
  return '€$thousands rb';
}
