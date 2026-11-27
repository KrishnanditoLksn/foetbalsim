import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../domain/models/game_models.dart';
import '../utils/format_utils.dart';

/// Potret pemain (dada ke atas) yang digambar prosedural.
///
/// Ciri wajah diturunkan dari identitas pemain ([AvatarLook.forPlayer]) sehingga
/// pemain yang sama selalu berwajah sama di layar mana pun. Kaus memakai warna
/// [club] (klub tujuan untuk berita transfer).
class PlayerAvatar extends StatelessWidget {
  const PlayerAvatar({
    super.key,
    required this.look,
    this.club,
    this.size = 56,
    this.borderColor,
  });

  PlayerAvatar.of(
    Player player, {
    Key? key,
    Club? club,
    double size = 56,
    Color? borderColor,
  }) : this(
         key: key,
         look: AvatarLook.forPlayer(player),
         club: club,
         size: size,
         borderColor: borderColor,
       );

  final AvatarLook look;
  final Club? club;
  final double size;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final shirt = club == null ? Chalk.grey : colorFromHex(club!.primaryColor);
    final trim = club == null ? Chalk.dim : colorFromHex(club!.secondaryColor);
    final radius = BorderRadius.circular(size * 0.16);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(
          color: borderColor ?? Chalk.line,
          width: size >= 56 ? 2 : 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: CustomPaint(
          painter: _AvatarPainter(
            look: look,
            shirt: shirt,
            trim: trim,
            // Kaus terang (mis. putih Madrid) butuh latar yang lebih gelap
            // agar tidak tenggelam: latar memakai warna kedua klub.
            background:
                Color.lerp(
                  Chalk.boardRaised,
                  shirt.computeLuminance() > 0.6 ? trim : shirt,
                  shirt.computeLuminance() > 0.6 ? 0.35 : 0.22,
                )!,
          ),
        ),
      ),
    );
  }
}

enum FaceShape { oval, square, narrow }

enum HairStyle { buzz, short, sidePart, curly, long, afro, slick, fade, bald }

/// Ciri visual avatar. Deterministik: input sama → hasil sama.
@immutable
class AvatarLook {
  const AvatarLook({
    required this.skin,
    required this.hair,
    required this.face,
    required this.style,
    required this.beard,
    required this.browTilt,
  });

  /// [seed] = identitas pemain, [age] menentukan uban, botak, dan jenggot.
  factory AvatarLook.from(String seed, {int age = 25}) {
    var h = _fnv1a(seed);
    int pick(int n) {
      h = _mix(h);
      return h % n;
    }

    final skin = _skins[pick(_skins.length)];
    final face = FaceShape.values[pick(FaceShape.values.length)];
    var hair = _hairColours[pick(_hairColours.length)];
    if (age >= 33 && pick(3) == 0) hair = const Color(0xFF9A9894);

    final styles = [...HairStyle.values]..remove(HairStyle.bald);
    var style = styles[pick(styles.length)];
    if (age >= 30 && pick(6) == 0) style = HairStyle.bald;

    // 0 = tanpa, 1 = tipis (cambang/kumis tipis), 2 = penuh.
    final beardRoll = pick(4);
    final beard = age < 22 ? 0 : const [0, 0, 1, 2][beardRoll];
    final browTilt = (pick(5) - 2) * 0.012;
    return AvatarLook(
      skin: skin,
      hair: hair,
      face: face,
      style: style,
      beard: beard,
      browTilt: browTilt,
    );
  }

  factory AvatarLook.forPlayer(Player p) =>
      AvatarLook.from('${p.id}|${p.firstName}|${p.lastName}', age: p.age);

  final Color skin;
  final Color hair;
  final FaceShape face;
  final HairStyle style;
  final int beard;
  final double browTilt;

  static const _skins = [
    Color(0xFFF2D3B8),
    Color(0xFFE5B993),
    Color(0xFFD29E73),
    Color(0xFFB57E55),
    Color(0xFF8D5A3B),
    Color(0xFF65402A),
  ];

  static const _hairColours = [
    Color(0xFF1C1712),
    Color(0xFF1C1712),
    Color(0xFF3A2618),
    Color(0xFF5C3B22),
    Color(0xFF8A6239),
    Color(0xFFC9A464),
  ];

  /// FNV-1a 32-bit: stabil di semua platform (berbeda dengan
  /// `String.hashCode`).
  static int _fnv1a(String s) {
    var h = 0x811C9DC5;
    for (final c in s.codeUnits) {
      h ^= c;
      h = (h * 0x01000193) & 0xFFFFFFFF;
    }
    return h;
  }

  static int _mix(int h) {
    h ^= h >> 16;
    h = (h * 0x45D9F3B) & 0xFFFFFFFF;
    h ^= h >> 16;
    return h;
  }

  @override
  bool operator ==(Object other) =>
      other is AvatarLook &&
      other.skin == skin &&
      other.hair == hair &&
      other.face == face &&
      other.style == style &&
      other.beard == beard &&
      other.browTilt == browTilt;

  @override
  int get hashCode => Object.hash(skin, hair, face, style, beard, browTilt);
}

class _AvatarPainter extends CustomPainter {
  _AvatarPainter({
    required this.look,
    required this.shirt,
    required this.trim,
    required this.background,
  });

  final AvatarLook look;
  final Color shirt;
  final Color trim;
  final Color background;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    Offset p(double x, double y) => Offset(x * s, y * s);
    Paint fill(Color c) => Paint()..color = c;

    canvas.drawRect(Offset.zero & size, fill(background));

    final skinShade = Color.lerp(look.skin, Colors.black, 0.18)!;
    final faceRect = switch (look.face) {
      FaceShape.oval => Rect.fromCenter(
        center: p(0.5, 0.44),
        width: 0.36 * s,
        height: 0.44 * s,
      ),
      FaceShape.square => Rect.fromCenter(
        center: p(0.5, 0.44),
        width: 0.38 * s,
        height: 0.42 * s,
      ),
      FaceShape.narrow => Rect.fromCenter(
        center: p(0.5, 0.45),
        width: 0.33 * s,
        height: 0.45 * s,
      ),
    };
    final facePath =
        look.face == FaceShape.square
            ? (Path()..addRRect(
              RRect.fromRectAndCorners(
                faceRect,
                topLeft: Radius.circular(0.16 * s),
                topRight: Radius.circular(0.16 * s),
                bottomLeft: Radius.circular(0.11 * s),
                bottomRight: Radius.circular(0.11 * s),
              ),
            ))
            : (Path()..addOval(faceRect));

    // Rambut belakang (gondrong, afro) di belakang kepala.
    final hairPaint = fill(look.hair);
    if (look.style == HairStyle.afro) {
      canvas.drawOval(
        Rect.fromCenter(
          center: p(0.5, 0.33),
          width: 0.56 * s,
          height: 0.46 * s,
        ),
        hairPaint,
      );
    } else if (look.style == HairStyle.long) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(
            faceRect.left - 0.04 * s,
            faceRect.top - 0.02 * s,
            faceRect.right + 0.04 * s,
            faceRect.top + 0.36 * s,
          ),
          Radius.circular(0.16 * s),
        ),
        hairPaint,
      );
    }

    // Kaus: bahu melengkung dengan kerah warna kedua.
    final shoulders =
        Path()
          ..moveTo(0.02 * s, s)
          ..cubicTo(0.04 * s, 0.80 * s, 0.22 * s, 0.74 * s, 0.38 * s, 0.73 * s)
          ..lineTo(0.62 * s, 0.73 * s)
          ..cubicTo(0.78 * s, 0.74 * s, 0.96 * s, 0.80 * s, 0.98 * s, s)
          ..close();
    canvas.drawPath(shoulders, fill(shirt));
    // Leher.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(0.42 * s, 0.56 * s, 0.58 * s, 0.78 * s),
        Radius.circular(0.04 * s),
      ),
      fill(skinShade),
    );
    // Kerah V.
    final collar =
        Paint()
          ..color = trim
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.5, 0.035 * s)
          ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      Path()
        ..moveTo(0.38 * s, 0.735 * s)
        ..lineTo(0.5 * s, 0.84 * s)
        ..lineTo(0.62 * s, 0.735 * s),
      collar,
    );

    // Telinga.
    for (final x in [faceRect.left, faceRect.right]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, faceRect.center.dy + 0.01 * s),
          width: 0.07 * s,
          height: 0.1 * s,
        ),
        fill(skinShade),
      );
    }
    canvas.drawPath(facePath, fill(look.skin));

    // Jenggot di rahang bawah.
    if (look.beard > 0) {
      canvas.save();
      canvas.clipPath(facePath);
      final beardPaint = fill(
        look.hair.withValues(alpha: look.beard == 2 ? 0.9 : 0.35),
      );
      canvas.drawRect(
        Rect.fromLTRB(
          faceRect.left,
          faceRect.top + faceRect.height * 0.66,
          faceRect.right,
          faceRect.bottom,
        ),
        beardPaint,
      );
      canvas.restore();
      // Bibir tetap terlihat di atas jenggot.
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
            faceRect.center.dx,
            faceRect.top + faceRect.height * 0.76,
          ),
          width: 0.12 * s,
          height: 0.05 * s,
        ),
        fill(look.skin),
      );
    }

    // Rambut depan: "topi" kepala dipotong pada garis rambut.
    final hairline = switch (look.style) {
      HairStyle.buzz => 0.2,
      HairStyle.short => 0.25,
      HairStyle.sidePart => 0.27,
      HairStyle.curly => 0.26,
      HairStyle.long => 0.26,
      HairStyle.afro => 0.24,
      HairStyle.slick => 0.21,
      HairStyle.fade => 0.22,
      HairStyle.bald => 0.0,
    };
    if (look.style != HairStyle.bald) {
      canvas.save();
      canvas.clipRect(
        Rect.fromLTRB(0, 0, s, faceRect.top + faceRect.height * hairline),
      );
      final cap = faceRect.inflate(
        look.style == HairStyle.buzz ? 0.006 * s : 0.025 * s,
      );
      canvas.drawOval(
        cap.translate(0, look.style == HairStyle.slick ? 0.0 : -0.01 * s),
        fill(
          look.style == HairStyle.buzz || look.style == HairStyle.fade
              ? look.hair.withValues(alpha: 0.8)
              : look.hair,
        ),
      );
      canvas.restore();

      switch (look.style) {
        case HairStyle.sidePart:
          // Poni miring ke satu sisi.
          canvas.drawPath(
            Path()
              ..moveTo(faceRect.left, faceRect.top + faceRect.height * 0.24)
              ..quadraticBezierTo(
                faceRect.center.dx,
                faceRect.top + faceRect.height * 0.08,
                faceRect.right,
                faceRect.top + faceRect.height * 0.34,
              )
              ..lineTo(faceRect.right, faceRect.top + faceRect.height * 0.1)
              ..lineTo(faceRect.left, faceRect.top + faceRect.height * 0.05)
              ..close(),
            hairPaint,
          );
        case HairStyle.curly:
          for (var i = 0; i < 6; i++) {
            final x = faceRect.left + faceRect.width * (0.08 + i * 0.168);
            canvas.drawCircle(
              Offset(x, faceRect.top + 0.01 * s),
              0.055 * s,
              hairPaint,
            );
          }
        case HairStyle.fade:
          // Bagian atas lebih tebal, sisi tipis.
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset(faceRect.center.dx, faceRect.top + 0.01 * s),
                width: faceRect.width * 0.62,
                height: 0.09 * s,
              ),
              Radius.circular(0.04 * s),
            ),
            hairPaint,
          );
        case HairStyle.buzz ||
            HairStyle.short ||
            HairStyle.long ||
            HairStyle.afro ||
            HairStyle.slick ||
            HairStyle.bald:
          break;
      }
    } else {
      // Sisa rambut tipis di samping kepala.
      for (final x in [faceRect.left, faceRect.right]) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(x, faceRect.top + faceRect.height * 0.36),
            width: 0.05 * s,
            height: 0.1 * s,
          ),
          fill(look.hair.withValues(alpha: 0.7)),
        );
      }
    }

    // Alis, mata, hidung, mulut.
    final ink = Color.lerp(look.hair, Colors.black, 0.3)!;
    final eyeY = faceRect.top + faceRect.height * 0.47;
    final dx = faceRect.width * 0.22;
    final brow =
        Paint()
          ..color = ink
          ..strokeWidth = math.max(1.2, 0.028 * s)
          ..strokeCap = StrokeCap.round;
    for (final side in [-1.0, 1.0]) {
      final cx = faceRect.center.dx + side * dx;
      final tilt = look.browTilt * s * side;
      canvas.drawLine(
        Offset(cx - 0.05 * s, eyeY - 0.06 * s + tilt),
        Offset(cx + 0.05 * s, eyeY - 0.06 * s - tilt),
        brow,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, eyeY),
          width: 0.05 * s,
          height: 0.035 * s,
        ),
        fill(const Color(0xFF1E1A17)),
      );
    }
    final line =
        Paint()
          ..color = Color.lerp(look.skin, Colors.black, 0.35)!
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1, 0.022 * s)
          ..strokeCap = StrokeCap.round;
    final noseY = faceRect.top + faceRect.height * 0.64;
    canvas.drawPath(
      Path()
        ..moveTo(faceRect.center.dx - 0.01 * s, eyeY + 0.03 * s)
        ..lineTo(faceRect.center.dx - 0.025 * s, noseY)
        ..lineTo(faceRect.center.dx + 0.02 * s, noseY),
      line,
    );
    final mouthY = faceRect.top + faceRect.height * 0.77;
    canvas.drawPath(
      Path()
        ..moveTo(faceRect.center.dx - 0.055 * s, mouthY)
        ..quadraticBezierTo(
          faceRect.center.dx,
          mouthY + 0.025 * s,
          faceRect.center.dx + 0.055 * s,
          mouthY - 0.005 * s,
        ),
      line..color = Color.lerp(look.skin, const Color(0xFF6B2A22), 0.55)!,
    );
  }

  @override
  bool shouldRepaint(_AvatarPainter old) =>
      old.look != look ||
      old.shirt != shirt ||
      old.trim != trim ||
      old.background != background;
}
