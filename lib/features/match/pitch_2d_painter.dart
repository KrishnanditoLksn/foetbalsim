import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'pitch_animator.dart';

/// Satu titik pemain yang siap digambar. Koordinat ternormalisasi 0–1
/// (x sepanjang lapangan, y selebar lapangan).
class PitchDot {
  const PitchDot({
    required this.x,
    required this.y,
    required this.fill,
    required this.stroke,
    required this.label,
    this.name,
  });

  final double x;
  final double y;
  final Color fill;
  final Color stroke;
  final String label; // nomor punggung
  final String? name; // ditampilkan bila pemain sedang menguasai bola
}

/// Lapangan 105 m × 68 m dengan titik pemain dan bola.
/// Pemakai wajib menjaga rasio kanvas 105:68 (lihat [AspectRatio]).
/// Dipakai untuk pratinjau statis (mis. layar taktik).
class Pitch2DPainter extends CustomPainter {
  Pitch2DPainter({required this.dots, this.ballX, this.ballY});

  final List<PitchDot> dots;
  final double? ballX;
  final double? ballY;

  @override
  void paint(Canvas canvas, Size size) {
    drawField(canvas, size);
    drawDots(canvas, size, dots);
    if (ballX != null && ballY != null) {
      drawBall(canvas, size, ballX!, ballY!);
    }
  }

  @override
  bool shouldRepaint(covariant Pitch2DPainter old) => true;

  // --- Gambar bersama (dipakai juga oleh [LivePitchPainter]) ----------------

  static const double _lengthM = 105;
  static const double _widthM = 68;

  static void drawField(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const stripes = 10;
    final light = Paint()..color = const Color(0xFF3E8E41);
    final dark = Paint()..color = const Color(0xFF368037);
    for (var i = 0; i < stripes; i++) {
      canvas.drawRect(
        Rect.fromLTWH(w * i / stripes, 0, w / stripes, h),
        i.isEven ? light : dark,
      );
    }

    final line =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.2, w * 0.004)
          ..color = Colors.white70;
    final mx = w / _lengthM; // px per meter (sumbu panjang)
    final my = h / _widthM; // px per meter (sumbu lebar)

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), line);
    canvas.drawLine(Offset(w / 2, 0), Offset(w / 2, h), line);
    canvas.drawCircle(Offset(w / 2, h / 2), 9.15 * my, line);
    canvas.drawCircle(
      Offset(w / 2, h / 2),
      0.4 * my,
      Paint()..color = Colors.white70,
    );

    // Kotak penalti (16,5 m × 40,3 m) dan kotak gawang (5,5 m × 18,3 m).
    final boxTop = (_widthM - 40.3) / 2 * my;
    final boxH = 40.3 * my;
    final goalTop = (_widthM - 18.3) / 2 * my;
    final goalH = 18.3 * my;
    for (final left in [true, false]) {
      final x0 = left ? 0.0 : w - 16.5 * mx;
      final g0 = left ? 0.0 : w - 5.5 * mx;
      canvas.drawRect(Rect.fromLTWH(x0, boxTop, 16.5 * mx, boxH), line);
      canvas.drawRect(Rect.fromLTWH(g0, goalTop, 5.5 * mx, goalH), line);
      final spotX = left ? 11 * mx : w - 11 * mx;
      canvas.drawCircle(
        Offset(spotX, h / 2),
        0.3 * my,
        Paint()..color = Colors.white70,
      );
    }
  }

  static void drawDots(Canvas canvas, Size size, List<PitchDot> dots) {
    final r = size.height * 0.035;
    final shadow = Paint()..color = Colors.black.withValues(alpha: 0.25);
    for (final d in dots) {
      final c = Offset(d.x * size.width, d.y * size.height);
      canvas.drawCircle(c + const Offset(0, 1), r, shadow);
      canvas.drawCircle(c, r, Paint()..color = d.fill);
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = d.stroke,
      );
      _text(canvas, d.label, c, r * 0.95, d.stroke, bold: true);
      if (d.name != null) {
        _text(
          canvas,
          d.name!,
          c.translate(0, -r * 1.9),
          r * 0.9,
          Colors.white,
          bold: true,
          shadow: true,
        );
      }
    }
  }

  static void drawBall(Canvas canvas, Size size, double x, double y) {
    final r = size.height * 0.035;
    final b = Offset(x * size.width, y * size.height);
    final br = r * 0.45;
    // Bayangan kecil di bawah bola agar terbaca di atas rumput.
    canvas.drawCircle(
      b + const Offset(0, 1.2),
      br,
      Paint()..color = Colors.black.withValues(alpha: 0.3),
    );
    canvas.drawCircle(b, br, Paint()..color = Colors.white);
    canvas.drawCircle(
      b,
      br,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = Colors.black87,
    );
  }

  static final Map<String, TextPainter> _textCache = {};

  static void _text(
    Canvas canvas,
    String text,
    Offset center,
    double fontSize,
    Color color, {
    bool bold = false,
    bool shadow = false,
  }) {
    final key =
        '$text|${fontSize.toStringAsFixed(1)}|${color.toARGB32()}|$bold|$shadow';
    var tp = _textCache[key];
    if (tp == null) {
      if (_textCache.length > 400) _textCache.clear();
      tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            shadows:
                shadow
                    ? const [Shadow(blurRadius: 3, color: Colors.black)]
                    : null,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      _textCache[key] = tp;
    }
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }
}

/// Painter laga live. Digambar ulang langsung oleh [PitchAnimator] lewat
/// `repaint`, sehingga widget tree tidak dibangun ulang tiap frame.
class LivePitchPainter extends CustomPainter {
  LivePitchPainter({
    required this.animator,
    required this.toDot,
  }) : super(repaint: animator);

  final PitchAnimator animator;

  /// Mengubah pose pemain menjadi titik gambar (warna, nomor, nama).
  final PitchDot Function(PlayerPose pose, bool hasBall) toDot;

  ui.Picture? _field;
  Size? _fieldSize;

  @override
  void paint(Canvas canvas, Size size) {
    // Latar lapangan direkam sekali per ukuran, lalu diputar ulang tiap frame.
    if (_field == null || _fieldSize != size) {
      final recorder = ui.PictureRecorder();
      final rc = Canvas(recorder);
      Pitch2DPainter.drawField(rc, size);
      _field = recorder.endRecording();
      _fieldSize = size;
    }
    canvas.drawPicture(_field!);

    final dots = [
      for (final p in animator.poses)
        toDot(p, p.dot.index == animator.carrier),
    ];
    Pitch2DPainter.drawDots(canvas, size, dots);
    Pitch2DPainter.drawBall(canvas, size, animator.ballX, animator.ballY);

    // Garis offside sesaat: tipis, kuning, sepanjang lapangan.
    final offside = animator.offsideX;
    if (offside != null) {
      final x = offside * size.width;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        Paint()
          ..strokeWidth = math.max(1.0, size.width * 0.003)
          ..color = const Color(0xCCFFEB3B),
      );
    }
  }

  @override
  bool shouldRepaint(covariant LivePitchPainter old) =>
      old.animator != animator || old.toDot != toDot;
}
