import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/l10n/legacy_text.dart';
import 'package:futbol/l10n/l10n.dart';

/// Teks Indonesia dari save lama → [Msg] yang bisa diterjemahkan.
void main() {
  String? en(String legacy) =>
      LegacyText.match(legacy)?.resolve(AppLanguage.en);

  test('judul & isi transfer selesai (format uang lama, titik desimal)', () {
    expect(
      en('Transfer selesai: Mikel Dubois'),
      'Transfer completed: Mikel Dubois',
    );
    expect(
      en(
        'Oliver Nielsen pindah dari Andorra ke Atlético Madrid dengan €3.7 jt.',
      ),
      'Oliver Nielsen moves from Andorra to Atlético Madrid for €3.7M.',
    );
    expect(
      en(
        'Ousmane Dubois pindah dari Castellón ke Villarreal dengan €6.5 jt (sell-on 10%).',
      ),
      'Ousmane Dubois moves from Castellón to Villarreal for €6.5M (sell-on 10%).',
    );
  });

  test('kalimat bersarang: berita bursa di dalam pesan', () {
    expect(
      en(
        'Real Oviedo menawarkan Mateo Johansson (DC, 28 th) seharga €5.3 jt. '
        'Cari pemain ini di Cari Pemain untuk menawar.',
      ),
      'Real Oviedo are offering Mateo Johansson (DC, 28 y/o) for €5.3M. '
      'Find him in Player Search to make a bid.',
    );
  });

  test('kata tetap dari kelompok yang sama (moral naik)', () {
    expect(
      en(
        'Villarreal: Iglesias. Penguasaan bola 58%-42%. Tembakan 9-13 '
        '(tepat sasaran 5-10). Moral skuad naik (+4).',
      ),
      'Villarreal: Iglesias. Possession 58%-42%. Shots 9-13 (on target 5-10). '
      'Squad morale up (+4).',
    );
  });

  test('kalimat versi lama yang sudah diganti di kamus', () {
    expect(
      en(
        'Barcelona menerima tawaran €36.6 jt (sell-on 10%). Aitor Gil '
        'mengharapkan gaji minimal €1.1 jt/tahun. Ajukan kontrak untuk '
        'menyelesaikan transfer.',
      ),
      "Barcelona accepted the €37M (sell-on 10%) offer. Aitor Gil's agent is "
      'waiting in the Negotiation Room to discuss wage, length and squad role.',
    );
  });

  test('teks yang tidak dikenal tidak diubah', () {
    expect(LegacyText.match('Teks bebas buatan sendiri'), isNull);
    expect(LegacyText.match('Halo'), isNull);
  });

  test('parseMoney menerima format lama dan baru', () {
    expect(LegacyText.parseMoney('€373 rb'), 373);
    expect(LegacyText.parseMoney('€1.2 jt'), 1200);
    expect(LegacyText.parseMoney('€1,2 jt'), 1200);
    expect(LegacyText.parseMoney('€12 jt'), 12000);
    expect(LegacyText.parseMoney('12 jt'), isNull);
  });

  test('bilangan urutan bahasa Inggris', () {
    String target(int n) => translate(AppLanguage.en, 'msg.boardWelcome.body', {
      'club': 'X',
      'manager': 'Y',
      'target': n,
    });
    expect(target(1), contains('finish 1st or better'));
    expect(target(2), contains('finish 2nd or better'));
    expect(target(3), contains('finish 3rd or better'));
    expect(target(11), contains('finish 11th or better'));
    expect(target(22), contains('finish 22nd or better'));
    expect(
      translate(AppLanguage.id, 'msg.boardWelcome.body', {
        'club': 'X',
        'manager': 'Y',
        'target': 2,
      }),
      contains('posisi 2 atau'),
    );
  });
}
