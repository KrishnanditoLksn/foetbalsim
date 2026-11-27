import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../domain/models/game_models.dart';
import '../utils/format_utils.dart';

/// Pengganti logo klub: perisai (bentuk dasar lambang klub) berwarna utama,
/// bertepi warna kedua, dengan inisial klub.
class ClubBadge extends StatelessWidget {
  const ClubBadge({super.key, required this.club, this.size = 44});

  final Club club;
  final double size;

  @override
  Widget build(BuildContext context) {
    final primary = colorFromHex(club.primaryColor);
    final secondary = colorFromHex(club.secondaryColor);
    final textColor =
        AppTheme.onColor(primary);

    return SizedBox(
      width: size * 0.86,
      height: size,
      child: CustomPaint(
        painter: _ShieldPainter(fill: primary, edge: secondary),
        child: Padding(
          padding: EdgeInsets.only(bottom: size * 0.16),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size * 0.1),
                child: Text(
                  club.shortName,
                  style: TextStyle(
                    fontFamily: Fonts.condensed,
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: size * 0.32,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  _ShieldPainter({required this.fill, required this.edge});

  final Color fill;
  final Color edge;

  static Path shield(Size s) {
    final w = s.width;
    final h = s.height;
    return Path()
      ..moveTo(w * 0.08, 0)
      ..lineTo(w * 0.92, 0)
      ..quadraticBezierTo(w, 0, w, h * 0.08)
      ..lineTo(w, h * 0.5)
      ..quadraticBezierTo(w * 0.96, h * 0.82, w * 0.5, h)
      ..quadraticBezierTo(w * 0.04, h * 0.82, 0, h * 0.5)
      ..lineTo(0, h * 0.08)
      ..quadraticBezierTo(0, 0, w * 0.08, 0)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = shield(size);
    canvas.drawPath(path, Paint()..color = fill);
    // Pita warna kedua di bagian atas, lalu tepi.
    canvas.save();
    canvas.clipPath(path);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.14),
      Paint()..color = edge,
    );
    canvas.restore();
    canvas.drawPath(
      path,
      Paint()
        ..color = edge
        ..style = PaintingStyle.stroke
        ..strokeWidth = (size.width * 0.06).clamp(1.0, 3.0),
    );
  }

  @override
  bool shouldRepaint(_ShieldPainter old) =>
      old.fill != fill || old.edge != edge;
}
