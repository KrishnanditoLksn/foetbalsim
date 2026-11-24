import 'package:flutter/material.dart';

import '../core/utils/format_utils.dart';
import '../domain/models/game_models.dart';

/// "Pizarra": papan taktik kapur milik manajer.
///
/// Papan slate hijau-abu, tulisan kapur putih, dan kapur berwarna yang
/// pudar untuk arti tetap (kuning = hari laga/sorotan, merah = keputusan
/// menunggu/bahaya, biru = info, hijau = positif). Aksen utama bukan warna
/// tetap: aksen adalah warna klub yang dilatih (lihat [AppTheme.accentFor]).
abstract final class Chalk {
  static const board = Color(0xFF22302A);
  static const boardDeep = Color(0xFF1A2520);
  static const boardRaised = Color(0xFF2B3B33);
  static const line = Color(0xFF3D5046);

  static const white = Color(0xFFECEAE1);
  static const dim = Color(0xFFA3AFA6);

  static const yellow = Color(0xFFE8CB6A);
  static const red = Color(0xFFE27D6B);
  static const blue = Color(0xFF93C4D4);
  static const green = Color(0xFFA3D18F);
  static const pink = Color(0xFFE3A1B8);
  static const grey = Color(0xFF7D8A82);
}

/// Nama keluarga font (lihat pubspec.yaml).
abstract final class Fonts {
  static const body = 'Barlow';
  static const condensed = 'BarlowCondensed';
}

/// Alias lama: komponen lama memakai nama-nama ini.
abstract final class FutbolColors {
  static const canvas = Chalk.board;
  static const card = Chalk.boardRaised;
  static const elevated = Chalk.boardRaised;
  static const border = Chalk.line;
  static const emerald = Chalk.green;
  static const amber = Chalk.yellow;
  static const cyan = Chalk.blue;
  static const coral = Chalk.red;
  static const rose = Chalk.pink;
  static const textPrimary = Chalk.white;
  static const textSecondary = Chalk.dim;
}

abstract final class AppTheme {
  /// Aksen dari warna klub: warna utama bila cukup berwarna, kalau tidak
  /// (mis. putih Real Madrid) warna kedua, kalau tidak kapur kuning. Warna
  /// yang terlalu gelap untuk papan dicerahkan agar tetap terbaca.
  static Color accentFor(Club? club) {
    if (club == null) return Chalk.yellow;
    for (final hex in [club.primaryColor, club.secondaryColor]) {
      final hsl = HSLColor.fromColor(colorFromHex(hex));
      if (hsl.saturation < 0.3 || hsl.lightness > 0.9 || hsl.lightness < 0.1) {
        continue;
      }
      final lightness = hsl.lightness.clamp(0.55, 0.72).toDouble();
      final saturation = hsl.saturation.clamp(0, 0.75).toDouble();
      return hsl.withLightness(lightness).withSaturation(saturation).toColor();
    }
    return Chalk.yellow;
  }

  /// Warna teks/ikon di atas [c].
  static Color onColor(Color c) =>
      c.computeLuminance() > 0.4 ? Chalk.boardDeep : Chalk.white;

  /// Tema papan, beraksen warna [club] bila ada karier aktif.
  static ThemeData board({Club? club}) {
    final accent = accentFor(club);
    final onAccent = onColor(accent);
    final scheme = ColorScheme(
      brightness: Brightness.dark,
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
      surfaceContainerLow: const Color(0xFF26352E),
      surfaceContainer: Chalk.boardRaised,
      surfaceContainerHigh: const Color(0xFF32443A),
      surfaceContainerHighest: const Color(0xFF3A4E43),
      outline: const Color(0xFF5A6E62),
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
      dividerTheme: const DividerThemeData(
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
        side: const BorderSide(color: Chalk.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        labelStyle: const TextStyle(
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
          side: const BorderSide(color: Chalk.dim),
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
          side: const BorderSide(color: Chalk.line),
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
        contentTextStyle: const TextStyle(
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
          borderSide: const BorderSide(color: Chalk.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Chalk.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: accent, width: 2),
        ),
      ),
      listTileTheme: const ListTileThemeData(iconColor: Chalk.dim),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: Chalk.line,
      ),
      badgeTheme: const BadgeThemeData(
        backgroundColor: Chalk.red,
        textColor: Chalk.boardDeep,
      ),
      popupMenuTheme: const PopupMenuThemeData(color: Chalk.boardRaised),
      dropdownMenuTheme: const DropdownMenuThemeData(
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
