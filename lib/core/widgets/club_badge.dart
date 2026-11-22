import 'package:flutter/material.dart';

import '../../domain/models/game_models.dart';
import '../utils/format_utils.dart';

/// Pengganti logo klub: lingkaran warna utama + tepi warna kedua + inisial.
class ClubBadge extends StatelessWidget {
  const ClubBadge({super.key, required this.club, this.size = 44});

  final Club club;
  final double size;

  @override
  Widget build(BuildContext context) {
    final primary = colorFromHex(club.primaryColor);
    final secondary = colorFromHex(club.secondaryColor);
    final textColor =
        primary.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primary,
        border: Border.all(color: secondary, width: size * 0.08),
      ),
      child: Text(
        club.shortName,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.28,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
