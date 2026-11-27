import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/app/theme.dart';
import 'package:futbol/core/widgets/player_avatar.dart';
import 'package:futbol/domain/models/game_models.dart';

/// README_TRANSFER_NEWS_DETAIL B: avatar deterministik + warna klub.
void main() {
  test('identitas sama → wajah sama', () {
    for (var i = 0; i < 50; i++) {
      expect(
        AvatarLook.from('$i|Mikel|Dubois', age: 24),
        AvatarLook.from('$i|Mikel|Dubois', age: 24),
      );
    }
  });

  test('pemain berbeda → wajah bervariasi', () {
    final looks = {
      for (var i = 0; i < 60; i++) AvatarLook.from('$i|Nama|Pemain', age: 26),
    };
    expect(looks.length, greaterThan(40));
    expect(looks.map((l) => l.skin).toSet().length, greaterThanOrEqualTo(4));
    expect(looks.map((l) => l.style).toSet().length, greaterThanOrEqualTo(6));
  });

  test('pemain muda tanpa jenggot dan tidak botak', () {
    for (var i = 0; i < 80; i++) {
      final look = AvatarLook.from('$i|Muda|Sekali', age: 18);
      expect(look.beard, 0);
      expect(look.style, isNot(HairStyle.bald));
    }
  });

  testWidgets('render dengan dan tanpa warna klub', (tester) async {
    const club = Club(
      id: 'barcelona',
      leagueId: 'l',
      name: 'Barcelona',
      shortName: 'BAR',
      primaryColor: '#A50044',
      secondaryColor: '#004D98',
      reputation: 1,
      stadiumName: 's',
      capacity: 1,
      balance: 0,
      transferBudget: 0,
      wageBudget: 0,
    );
    final look = AvatarLook.from('7|Pedro|Ruiz', age: 34);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.board(),
        home: Scaffold(
          body: Row(
            children: [
              PlayerAvatar(look: look, club: club, size: 68),
              PlayerAvatar(look: look, size: 40),
            ],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(PlayerAvatar), findsNWidgets(2));
    expect(tester.getSize(find.byType(PlayerAvatar).first), const Size(68, 68));
  });
}
