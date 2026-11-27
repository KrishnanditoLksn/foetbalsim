import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/app/theme.dart';
import 'package:futbol/domain/models/game_models.dart';

Club _club(String name, String primary, String secondary) => Club(
  id: name,
  leagueId: 'l',
  name: name,
  shortName: name.substring(0, 3).toUpperCase(),
  primaryColor: primary,
  secondaryColor: secondary,
  reputation: 50,
  stadiumName: 's',
  capacity: 1,
  balance: 0,
  transferBudget: 0,
  wageBudget: 0,
);

double _hue(Color c) => HSLColor.fromColor(c).hue;

double _contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  final barca = _club('Barcelona', '#A50044', '#004D98');
  final madrid = _club('Real Madrid', '#FFFFFF', '#FEBE10');
  final athletic = _club('Athletic Club', '#EE2523', '#FFFFFF');
  final villarreal = _club('Villarreal', '#FFE600', '#005187');
  final valencia = _club('Valencia', '#000000', '#F26B1D');

  test('Barcelona: papan biru tua, aksen grana (blaugrana)', () {
    final p = ClubPalette.forClub(barca);
    expect(p.brightness, Brightness.dark);
    expect(_hue(p.board), inInclusiveRange(200, 230));
    expect(_hue(p.accent), inInclusiveRange(320, 345));
  });

  test('Real Madrid: papan putih, aksen emas', () {
    final p = ClubPalette.forClub(madrid);
    expect(p.brightness, Brightness.light);
    expect(p.board.computeLuminance(), greaterThan(0.8));
    expect(_hue(p.accent), inInclusiveRange(38, 50));
  });

  test('Athletic: papan merah, aksen kapur putih (rojiblancos)', () {
    final p = ClubPalette.forClub(athletic);
    expect(p.brightness, Brightness.dark);
    final h = _hue(p.board);
    expect(h < 15 || h > 345, isTrue, reason: 'hue $h');
    expect(HSLColor.fromColor(p.board).saturation, greaterThan(0.3));
    expect(p.accent, const Color(0xFFFFFFFF));
  });

  test('warna kuning tidak jadi papan; hitam jadi arang', () {
    expect(_hue(ClubPalette.forClub(villarreal).board), inInclusiveRange(195, 215));
    final v = ClubPalette.forClub(valencia);
    expect(HSLColor.fromColor(v.board).saturation, lessThan(0.1));
    expect(_hue(v.accent), inInclusiveRange(15, 30));
  });

  test('tanpa karier: papan netral, bukan hijau', () {
    final p = ClubPalette.forClub(null);
    expect(p, ClubPalette.neutral);
    expect(HSLColor.fromColor(p.board).saturation, lessThan(0.15));
  });

  test('tulisan dan aksen terbaca di semua papan klub', () {
    for (final c in [barca, madrid, athletic, villarreal, valencia]) {
      final p = ClubPalette.forClub(c);
      expect(_contrast(p.ink, p.board), greaterThan(7), reason: c.name);
      expect(_contrast(p.dim, p.board), greaterThan(3.5), reason: c.name);
      expect(_contrast(p.accent, p.board), greaterThan(3), reason: c.name);
      for (final k in [p.yellow, p.red, p.blue, p.green]) {
        expect(_contrast(k, p.board), greaterThan(3), reason: '${c.name} $k');
      }
    }
  });

  test('AppTheme.board memasang palet aktif', () {
    final t = AppTheme.board(club: madrid);
    expect(Chalk.palette, ClubPalette.forClub(madrid));
    expect(t.colorScheme.brightness, Brightness.light);
    expect(t.scaffoldBackgroundColor, Chalk.board);
    AppTheme.board();
    expect(Chalk.palette, ClubPalette.neutral);
  });
}
