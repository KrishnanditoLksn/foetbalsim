import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../domain/enums/position.dart';
import '../utils/format_utils.dart';

/// Komponen kecil gaya "pizarra" yang dipakai di semua layar.
///
/// Angka memakai Barlow Condensed dengan digit sama lebar agar kolom angka
/// sejajar, seperti papan skor.
const tabular = [FontFeature.tabularFigures()];

/// Gaya angka papan skor.
TextStyle scoreStyle({
  double size = 20,
  Color? color,
  FontWeight weight = FontWeight.w700,
}) => TextStyle(
  fontFamily: Fonts.condensed,
  fontSize: size,
  fontWeight: weight,
  height: 1,
  color: color,
  fontFeatures: tabular,
);

// --- Warna berkode ----------------------------------------------------------

/// Warna kapur kelompok posisi: GK kuning, bek biru, gelandang hijau,
/// penyerang merah muda.
Color positionColor(PositionGroup g) => switch (g) {
  PositionGroup.goalkeeper => Chalk.yellow,
  PositionGroup.defender => Chalk.blue,
  PositionGroup.midfielder => Chalk.green,
  PositionGroup.forward => Chalk.pink,
};

/// Nama pendek kelompok posisi untuk chip filter.
String positionGroupShort(PositionGroup g) => switch (g) {
  PositionGroup.goalkeeper => 'Kiper',
  PositionGroup.defender => 'Bek',
  PositionGroup.midfielder => 'Gelandang',
  PositionGroup.forward => 'Penyerang',
};

/// Warna rating CA (1–200).
Color ratingColor(int ca) {
  if (ca >= 160) return Chalk.yellow;
  if (ca >= 130) return Chalk.green;
  if (ca >= 100) return Chalk.blue;
  if (ca >= 70) return Chalk.dim;
  return Chalk.red;
}

/// Warna kondisi fisik (0–100).
Color conditionColor(int condition) {
  if (condition >= 80) return Chalk.green;
  if (condition >= 60) return Chalk.yellow;
  return Chalk.red;
}

/// Warna atribut 1–20: merah (lemah), abu, hijau, kuning (elite).
Color attributeBoxColor(int value) {
  if (value <= 8) return Chalk.red;
  if (value <= 12) return Chalk.grey;
  if (value <= 16) return Chalk.green;
  return Chalk.yellow;
}

// --- Komponen ---------------------------------------------------------------

/// Kode posisi (mis. `DC`) dengan garis kapur berwarna di kiri.
class PositionBadge extends StatelessWidget {
  const PositionBadge(this.position, {super.key, this.width = 40});

  final Position position;
  final double width;

  @override
  Widget build(BuildContext context) {
    final color = positionColor(position.group);
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      alignment: Alignment.center,
      child: Text(
        position.label,
        style: TextStyle(
          fontFamily: Fonts.condensed,
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Angka CA besar berwarna, dengan bintang opsional.
class RatingPill extends StatelessWidget {
  const RatingPill(this.ca, {super.key, this.showStars = false});

  final int ca;
  final bool showStars;

  @override
  Widget build(BuildContext context) {
    final number = Text(
      '$ca',
      style: scoreStyle(size: 22, color: ratingColor(ca)),
    );
    if (!showStars) return number;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        number,
        const SizedBox(height: 3),
        StarRow(stars: caToStars(ca)),
      ],
    );
  }
}

/// Lima bintang kecil (bintang dari CA/PA).
class StarRow extends StatelessWidget {
  const StarRow({super.key, required this.stars, this.size = 11});

  final int stars;
  final double size;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 1; i <= 5; i++)
        Icon(
          i <= stars ? Icons.star_rounded : Icons.star_outline_rounded,
          size: size,
          color: i <= stars ? Chalk.yellow : Chalk.line,
        ),
    ],
  );
}

/// Garis kondisi tipis seperti coretan kapur, plus persen.
class ConditionBar extends StatelessWidget {
  const ConditionBar(
    this.condition, {
    super.key,
    this.width = 56,
    this.showLabel = true,
  });

  final int condition;
  final double width;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final color = conditionColor(condition);
    final filled = width * (condition / 100).clamp(0, 1);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: width,
          height: 4,
          child: Stack(
            children: [
              Container(color: Chalk.line),
              Container(width: filled, color: color),
            ],
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 6),
          Text('$condition%', style: scoreStyle(size: 14, color: color)),
        ],
      ],
    );
  }
}

/// Hasil laga terakhir. Input `W`/`D`/`L` (dari klasemen) ditampilkan
/// sebagai huruf M (menang), S (seri), K (kalah) dalam kotak kecil.
class FormDots extends StatelessWidget {
  const FormDots(this.form, {super.key, this.size = 18, this.showEmpty = 0});

  final List<String> form;
  final double size;

  /// Jumlah slot minimal; slot kosong digambar sebagai garis putus.
  final int showEmpty;

  static Color colorOf(String r) => switch (r) {
    'W' => Chalk.green,
    'D' => Chalk.grey,
    _ => Chalk.red,
  };

  static String letterOf(String r) => switch (r) {
    'W' => 'M',
    'D' => 'S',
    _ => 'K',
  };

  @override
  Widget build(BuildContext context) {
    final empty = (showEmpty - form.length).clamp(0, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final r in form)
          Container(
            width: size,
            height: size,
            margin: const EdgeInsets.only(right: 3),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorOf(r),
              borderRadius: BorderRadius.circular(2),
            ),
            child:
                size >= 14
                    ? Text(
                      letterOf(r),
                      style: TextStyle(
                        fontFamily: Fonts.condensed,
                        color: Chalk.boardDeep,
                        fontSize: size * 0.7,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    )
                    : null,
          ),
        for (var i = 0; i < empty; i++)
          Container(
            width: size,
            height: size,
            margin: const EdgeInsets.only(right: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: Chalk.line),
            ),
          ),
      ],
    );
  }
}

/// Judul bagian: huruf kalimat, condensed, dengan garis kapur di bawahnya.
class SectionHeader extends StatelessWidget {
  const SectionHeader(
    this.title, {
    super.key,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(0, 22, 0, 6),
  });

  final String title;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: Fonts.condensed,
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                    color: Chalk.white,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 4),
          const Divider(color: Chalk.dim, thickness: 1.2),
        ],
      ),
    );
  }
}

/// Angka besar dengan label kecil di bawahnya (tanpa kotak). Dipakai
/// berderet dalam [StatStrip].
class StatFigure extends StatelessWidget {
  const StatFigure({
    super.key,
    required this.label,
    this.value,
    this.child,
    this.color,
  }) : assert(value != null || child != null);

  final String label;
  final String? value;

  /// Isi pengganti [value] (mis. [FormDots]).
  final Widget? child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 30,
          child: Align(
            alignment: Alignment.bottomLeft,
            // Mengecil bila sempit (layar kecil, teks besar) alih-alih overflow.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.bottomLeft,
              child:
                  child ??
                  Text(
                    value!,
                    style: scoreStyle(size: 30, color: color ?? Chalk.white),
                  ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, color: Chalk.dim),
        ),
      ],
    );
  }
}

/// Deretan [StatFigure] yang dipisah garis kapur vertikal.
class StatStrip extends StatelessWidget {
  const StatStrip({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: VerticalDivider(width: 1, color: Chalk.line),
              ),
            Expanded(child: children[i]),
          ],
        ],
      ),
    );
  }
}

/// Penanda status kecil berwarna (mis. status negosiasi). Huruf kalimat.
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.label, {super.key, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Angka atribut 1–20 berkode warna (grid atribut gaya FM).
class AttributeBox extends StatelessWidget {
  const AttributeBox(this.value, {super.key});

  final int value;

  @override
  Widget build(BuildContext context) {
    final color = attributeBoxColor(value);
    return Container(
      width: 30,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        '$value',
        style: scoreStyle(
          size: 17,
          color: color == Chalk.grey ? Chalk.white : color,
        ),
      ),
    );
  }
}
