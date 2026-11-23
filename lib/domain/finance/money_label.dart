/// Label uang untuk pesan inbox dan dialog. Nilai dalam ribuan euro (€K).
String moneyLabel(int thousands) => thousands >= 1000
    ? '€${(thousands / 1000).toStringAsFixed(1)} jt'
    : '€$thousands rb';
