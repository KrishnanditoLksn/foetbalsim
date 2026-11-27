import '../../l10n/formatters.dart';

/// Label uang untuk pesan inbox dan dialog. Nilai dalam ribuan euro (€K),
/// diformat sesuai bahasa aktif.
String moneyLabel(int thousands) => formatMoney(thousands);
