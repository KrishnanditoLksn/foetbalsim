import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/utils/format_utils.dart';
import '../domain/models/game_models.dart';

/// Satu set warna papan. Papan diwarnai identitas klub yang dilatih
/// (lihat [ClubPalette.forClub]): Barcelona papan biru tua beraksen grana,
/// Athletic papan merah berkapur putih, Real Madrid papan putih beraksen emas.
@immutable
class ClubPalette {
  const ClubPalette({
    required this.brightness,
    required this.board,
    required this.boardDeep,
    required this.boardRaised,
    required this.line,
    required this.ink,
    required this.dim,
    required this.accent,
    required this.yellow,
    required this.red,
    required this.blue,
    required this.green,
    required this.pink,
    required this.grey,
  });

  final Brightness brightness;
  final Color board;
  final Color boardDeep;
  final Color boardRaised;
  final Color line;

  /// Warna tulisan utama ("kapur"): terang di papan gelap, gelap di papan
  /// terang.
  final Color ink;
  final Color dim;

  /// Aksen utama (tombol, indikator terpilih).
  final Color accent;

  // Kapur berwarna untuk arti tetap (kuning = hari laga/sorotan, merah =
  // keputusan menunggu/bahaya, biru = info, hijau = positif).
  final Color yellow;
  final Color red;
  final Color blue;
  final Color green;
  final Color pink;
  final Color grey;

  bool get isLight => brightness == Brightness.light;

  /// Papan netral (grafit) untuk menu awal dan karier baru.
  static const neutral = ClubPalette(
    brightness: Brightness.dark,
    board: Color(0xFF202327),
    boardDeep: Color(0xFF181A1E),
    boardRaised: Color(0xFF292D32),
    line: Color(0xFF3B4047),
    ink: Color(0xFFECEAE1),
    dim: Color(0xFFA5A9AE),
    accent: Color(0xFFE8CB6A),
    yellow: Color(0xFFE8CB6A),
    red: Color(0xFFE27D6B),
    blue: Color(0xFF93C4D4),
    green: Color(0xFFA3D18F),
    pink: Color(0xFFE3A1B8),
    grey: Color(0xFF80868D),
  );

  /// Palet dari warna [club].
  ///
  /// - Warna utama putih (Real Madrid, Zaragoza, …) → papan terang, aksen
  ///   warna kedua.
  /// - Dua warna yang sama-sama kuat (Barcelona, Levante, Osasuna, …) → papan
  ///   dari warna yang lebih gelap, aksen dari yang lain: blaugrana.
  /// - Warna utama kuning (Villarreal, Cádiz) → papan dari warna kedua.
  /// - Selain itu → papan dari warna utama yang digelapkan; bila warna kedua
  ///   putih/hitam (Athletic: merah-putih), aksennya kapur putih.
  static ClubPalette forClub(Club? club) {
    if (club == null) return neutral;
    final p = HSLColor.fromColor(colorFromHex(club.primaryColor));
    final s = HSLColor.fromColor(colorFromHex(club.secondaryColor));

    if (_isWhite(p)) return _light(accentFrom: s);

    var base = p;
    HSLColor? other = s;
    if (_isColourful(p) && _isColourful(s)) {
      final pLum = p.toColor().computeLuminance();
      final sLum = s.toColor().computeLuminance();
      if (_isYellow(p) || sLum < pLum) (base, other) = (s, p);
    } else if (!_isColourful(p) && _isColourful(s)) {
      // Mis. Valencia: hitam-oranye → papan arang, aksen oranye.
      (base, other) = (p, s);
    }
    if (!_isColourful(other)) other = null;
    return _dark(base: base, accentFrom: other);
  }

  static bool _isWhite(HSLColor c) => c.lightness > 0.85;
  static bool _isColourful(HSLColor c) =>
      c.saturation >= 0.3 && c.lightness > 0.12 && c.lightness < 0.9;
  static bool _isYellow(HSLColor c) =>
      c.hue >= 40 && c.hue <= 70 && c.lightness >= 0.45;

  static Color _hsl(double h, double s, double l) =>
      HSLColor.fromAHSL(1, h, s.clamp(0, 1), l.clamp(0, 1)).toColor();

  static double _contrast(Color a, Color b) {
    final la = a.computeLuminance(), lb = b.computeLuminance();
    return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
  }

  /// Warna klub [c] digeser terang/gelapnya sampai kontrasnya dengan [board]
  /// minimal 3:1 (cukup untuk tombol dan indikator), hue tetap.
  static Color _readableOn(Color board, HSLColor c, {required bool lighten}) {
    var hsl = c.withSaturation(c.saturation.clamp(0, 0.85));
    hsl = hsl.withLightness(
      lighten ? math.max(hsl.lightness, 0.55) : math.min(hsl.lightness, 0.45),
    );
    for (var i = 0; i < 20 && _contrast(hsl.toColor(), board) < 3.2; i++) {
      final l = hsl.lightness + (lighten ? 0.025 : -0.025);
      hsl = hsl.withLightness(l.clamp(0, 1));
    }
    return hsl.toColor();
  }

  static ClubPalette _dark({required HSLColor base, HSLColor? accentFrom}) {
    final h = base.hue;
    // Papan tetap gelap agar kapur terbaca, tapi warnanya jelas warna klub.
    final sat =
        _isColourful(base) ? (base.saturation * 0.7).clamp(0.3, 0.6) : 0.06;
    final board = _hsl(h, sat, 0.17);
    final ink = Color.lerp(const Color(0xFFF3F1EA), _hsl(h, 0.3, 0.9), 0.15)!;
    final accent =
        accentFrom == null
            // Warna kedua putih/hitam: aksen kapur putih bersih.
            ? const Color(0xFFFFFFFF)
            : _readableOn(board, accentFrom, lighten: true);
    return ClubPalette(
      brightness: Brightness.dark,
      board: board,
      boardDeep: _hsl(h, sat, 0.12),
      boardRaised: _hsl(h, sat * 0.9, 0.22),
      line: _hsl(h, sat * 0.6, 0.3),
      ink: ink,
      dim: Color.lerp(ink, board, 0.35)!,
      accent: accent,
      yellow: const Color(0xFFE8CB6A),
      // Di papan merah, kapur merah dibuat lebih terang agar tetap menonjol.
      red: (h < 20 || h > 340) && sat > 0.3
          ? const Color(0xFFFFA390)
          : const Color(0xFFE27D6B),
      blue: const Color(0xFF93C4D4),
      green: const Color(0xFFA3D18F),
      pink: const Color(0xFFE3A1B8),
      grey: Color.lerp(ink, board, 0.55)!,
    );
  }

  static ClubPalette _light({required HSLColor accentFrom}) {
    const ink = Color(0xFF1B2130);
    const board = Color(0xFFF4F2EC);
    final accent =
        _isColourful(accentFrom)
            ? _readableOn(board, accentFrom, lighten: false)
            : ink;
    return ClubPalette(
      brightness: Brightness.light,
      board: board,
      boardDeep: const Color(0xFFE9E6DD),
      boardRaised: const Color(0xFFFFFFFF),
      line: const Color(0xFFD9D5CA),
      ink: ink,
      dim: const Color(0xFF5E6573),
      accent: accent,
      yellow: const Color(0xFF9A6B00),
      red: const Color(0xFFB83C2B),
      blue: const Color(0xFF2B6A86),
      green: const Color(0xFF3B7A2C),
      pink: const Color(0xFFA5426A),
      grey: const Color(0xFF8A8F98),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ClubPalette &&
      other.brightness == brightness &&
      other.board == board &&
      other.accent == accent &&
      other.ink == ink;

  @override
  int get hashCode => Object.hash(brightness, board, accent, ink);
}

/// "Pizarra": papan taktik kapur milik manajer.
///
/// Warna papan mengikuti identitas klub yang dilatih: nilai di sini dibaca
/// dari [palette] aktif, yang diatur oleh [AppTheme.board]. Karena itu
/// nilai-nilai ini bukan `const`.
abstract final class Chalk {
  static ClubPalette palette = ClubPalette.neutral;

  static Color get board => palette.board;
  static Color get boardDeep => palette.boardDeep;
  static Color get boardRaised => palette.boardRaised;
  static Color get line => palette.line;

  /// Warna tulisan utama. Namanya tetap `white` demi kompatibilitas; di papan
  /// terang (Real Madrid) warnanya gelap.
  static Color get white => palette.ink;
  static Color get dim => palette.dim;

  static Color get yellow => palette.yellow;
  static Color get red => palette.red;
  static Color get blue => palette.blue;
  static Color get green => palette.green;
  static Color get pink => palette.pink;
  static Color get grey => palette.grey;
}

/// Nama keluarga font (lihat pubspec.yaml).
abstract final class Fonts {
  static const body = 'Barlow';
  static const condensed = 'BarlowCondensed';
}

/// Alias lama: komponen lama memakai nama-nama ini.
abstract final class FutbolColors {
  static Color get canvas => Chalk.board;
  static Color get card => Chalk.boardRaised;
  static Color get elevated => Chalk.boardRaised;
  static Color get border => Chalk.line;
  static Color get emerald => Chalk.green;
  static Color get amber => Chalk.yellow;
  static Color get cyan => Chalk.blue;
  static Color get coral => Chalk.red;
  static Color get rose => Chalk.pink;
  static Color get textPrimary => Chalk.white;
  static Color get textSecondary => Chalk.dim;
}

abstract final class AppTheme {
  /// Aksen papan untuk [club] (lihat [ClubPalette.forClub]).
  static Color accentFor(Club? club) => ClubPalette.forClub(club).accent;

  static const _darkInk = Color(0xFF1A1D22);
  static const _lightInk = Color(0xFFF5F3EC);

  /// Warna teks/ikon di atas [c]. Tetap (tidak ikut palet), karena [c] bisa
  /// warna apa saja (mis. kepala Beranda dalam warna klub).
  static Color onColor(Color c) =>
      c.computeLuminance() > 0.4 ? _darkInk : _lightInk;

  /// Tema papan dalam warna identitas [club] bila ada karier aktif.
  /// Sekaligus mengatur [Chalk.palette] agar widget yang memakai `Chalk.*`
  /// ikut berganti warna.
  static ThemeData board({Club? club}) {
    final palette = ClubPalette.forClub(club);
    Chalk.palette = palette;
    final accent = palette.accent;
    final onAccent = onColor(accent);
    final scheme = ColorScheme(
      brightness: palette.brightness,
      primary: accent,
      onPrimary: onAccent,
      primaryContainer: Color.lerp(Chalk.board, accent, 0.28)!,
      onPrimaryContainer: Chalk.white,
      secondary: Chalk.blue,
      onSecondary: Chalk.boardDeep,
      secondaryContainer: Color.lerp(Chalk.board, Chalk.blue, 0.25)!,
      onSecondaryContainer: Chalk.white,
      tertiary: Chalk.yellow,
      onTertiary: Chalk.boardDeep,
      tertiaryContainer: Color.lerp(Chalk.board, Chalk.yellow, 0.22)!,
      onTertiaryContainer: Chalk.white,
      error: Chalk.red,
      onError: Chalk.boardDeep,
      errorContainer: Color.lerp(Chalk.board, Chalk.red, 0.25)!,
      onErrorContainer: Chalk.white,
      surface: Chalk.board,
      onSurface: Chalk.white,
      onSurfaceVariant: Chalk.dim,
      surfaceContainerLowest: Chalk.boardDeep,
      surfaceContainerLow: Color.lerp(Chalk.board, Chalk.boardRaised, 0.5)!,
      surfaceContainer: Chalk.boardRaised,
      surfaceContainerHigh: Color.lerp(Chalk.boardRaised, Chalk.line, 0.4)!,
      surfaceContainerHighest: Color.lerp(Chalk.boardRaised, Chalk.line, 0.7)!,
      outline: Color.lerp(Chalk.line, Chalk.dim, 0.4)!,
      outlineVariant: Chalk.line,
      inverseSurface: Chalk.white,
      onInverseSurface: Chalk.board,
      inversePrimary: accent,
      shadow: Colors.black,
      scrim: Colors.black,
    );

    final base = ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      fontFamily: Fonts.body,
    );
    final t = base.textTheme.apply(
      bodyColor: Chalk.white,
      displayColor: Chalk.white,
    );
    TextStyle? cond(TextStyle? s, double size, FontWeight w) => s?.copyWith(
      fontFamily: Fonts.condensed,
      fontSize: size,
      fontWeight: w,
      height: 1.1,
    );
    final text = t.copyWith(
      displaySmall: cond(t.displaySmall, 40, FontWeight.w700),
      headlineMedium: cond(t.headlineMedium, 32, FontWeight.w700),
      headlineSmall: cond(t.headlineSmall, 28, FontWeight.w700),
      titleLarge: cond(t.titleLarge, 24, FontWeight.w700),
      titleMedium: t.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: t.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      bodyMedium: t.bodyMedium?.copyWith(fontSize: 15, height: 1.35),
      bodySmall: t.bodySmall?.copyWith(fontSize: 13, color: Chalk.dim),
      labelLarge: t.labelLarge?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: Chalk.board,
      textTheme: text,
      dividerTheme: DividerThemeData(
        color: Chalk.line,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Chalk.board,
        foregroundColor: Chalk.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: text.titleLarge?.copyWith(fontSize: 26),
      ),
      // Kartu hanya untuk yang benar-benar terangkat (papan laga, panel).
      cardTheme: CardThemeData(
        color: Chalk.boardRaised,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Chalk.boardDeep,
        surfaceTintColor: Colors.transparent,
        indicatorColor: accent.withValues(alpha: 0.22),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            color: s.contains(WidgetState.selected) ? accent : Chalk.dim,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => TextStyle(
            fontFamily: Fonts.body,
            fontSize: 12,
            fontWeight:
                s.contains(WidgetState.selected)
                    ? FontWeight.w700
                    : FontWeight.w500,
            color: s.contains(WidgetState.selected) ? Chalk.white : Chalk.dim,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        selectedColor: accent.withValues(alpha: 0.2),
        side: BorderSide(color: Chalk.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        labelStyle: TextStyle(
          fontFamily: Fonts.body,
          color: Chalk.white,
          fontWeight: FontWeight.w600,
        ),
        checkmarkColor: accent,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 46),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          textStyle: const TextStyle(
            fontFamily: Fonts.body,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 46),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          side: BorderSide(color: Chalk.dim),
          foregroundColor: Chalk.white,
          textStyle: const TextStyle(
            fontFamily: Fonts.body,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: const TextStyle(
            fontFamily: Fonts.body,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          side: BorderSide(color: Chalk.line),
          selectedBackgroundColor: accent.withValues(alpha: 0.2),
          selectedForegroundColor: Chalk.white,
          foregroundColor: Chalk.dim,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: Chalk.white,
        unselectedLabelColor: Chalk.dim,
        indicatorColor: accent,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Chalk.line,
        labelStyle: const TextStyle(
          fontFamily: Fonts.body,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: Fonts.body,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Chalk.boardRaised,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        titleTextStyle: text.titleLarge,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Chalk.white,
        contentTextStyle: TextStyle(
          fontFamily: Fonts.body,
          color: Chalk.boardDeep,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: Color.lerp(accent, Chalk.boardDeep, 0.35),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Chalk.boardDeep,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Chalk.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Chalk.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: accent, width: 2),
        ),
      ),
      listTileTheme: ListTileThemeData(iconColor: Chalk.dim),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: Chalk.line,
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: Chalk.red,
        textColor: Chalk.boardDeep,
      ),
      popupMenuTheme: PopupMenuThemeData(color: Chalk.boardRaised),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(Chalk.boardRaised),
        ),
      ),
    );
  }

  /// Tema tanpa karier aktif (menu awal, karier baru).
  static ThemeData dark() => board();

  /// Dipertahankan untuk kompatibilitas; aplikasi selalu memakai papan.
  static ThemeData light() => board();
}
