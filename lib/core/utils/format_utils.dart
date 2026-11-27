import 'dart:math' as math;

import 'package:flutter/material.dart';

export '../../l10n/formatters.dart' show formatMoney;

/// Parse warna "#RRGGBB" dari seed JSON menjadi [Color] (alpha penuh).
Color colorFromHex(String hex) {
  final clean = hex.replaceFirst('#', '');
  return Color(int.parse('FF$clean', radix: 16));
}

/// Konversi Current Ability (1–200) ke bintang 1–5.
int caToStars(int ca) => math.max(1, math.min(5, (ca / 40).ceil()));

/// Warna skala atribut 1–20: merah (lemah) → biru (elite).
Color attributeColor(int value) {
  if (value <= 5) return const Color(0xFFD32F2F);
  if (value <= 9) return const Color(0xFFF57C00);
  if (value <= 12) return const Color(0xFFFBC02D);
  if (value <= 15) return const Color(0xFF7CB342);
  if (value <= 18) return const Color(0xFF2E7D32);
  return const Color(0xFF1565C0);
}
