import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/enums/squad_status.dart';
import 'package:futbol/domain/enums/transfer.dart';
import 'package:futbol/domain/models/transfer_news_payload.dart';

/// README_TRANSFER_NEWS_DETAIL D: payload `tx:` dan kompatibilitas payload
/// lama di `InboxMessages.payload`.
void main() {
  final full = TransferNewsPayload(
    playerId: 142,
    playerName: 'Mikel Dubois',
    fromClubId: 'castellon',
    toClubId: 'girona',
    status: TransferNewsStatus.completed,
    transferType: TransferType.aiDeal,
    fee: 373,
    installmentYears: 2,
    sellOnPct: 15,
    contractYears: 3,
    contractEndDate: DateTime.utc(2028, 6, 30),
    wage: 180,
    squadStatus: SquadStatus.rotation,
    offerId: 18,
  );

  test('encode → tryParse mengembalikan data yang sama', () {
    final raw = full.encode();
    expect(raw, startsWith('tx:{'));
    final back = TransferNewsPayload.tryParse(raw)!;
    expect(back.playerId, 142);
    expect(back.playerName, 'Mikel Dubois');
    expect(back.fromClubId, 'castellon');
    expect(back.toClubId, 'girona');
    expect(back.status, TransferNewsStatus.completed);
    expect(back.transferType, TransferType.aiDeal);
    expect(back.fee, 373);
    expect(back.installmentYears, 2);
    expect(back.sellOnPct, 15);
    expect(back.contractYears, 3);
    expect(back.contractEndDate, DateTime.utc(2028, 6, 30));
    expect(back.wage, 180);
    expect(back.squadStatus, SquadStatus.rotation);
    expect(back.offerId, 18);
  });

  test('kolom opsional kosong tetap aman', () {
    const minimal = TransferNewsPayload(
      playerId: 1,
      playerName: 'A B',
      fromClubId: 'x',
      toClubId: 'y',
      status: TransferNewsStatus.rejected,
      fee: 50,
    );
    final back = TransferNewsPayload.tryParse(minimal.encode())!;
    expect(back.installmentYears, 1);
    expect(back.sellOnPct, 0);
    expect(back.contractEndDate, isNull);
    expect(back.wage, isNull);
    expect(back.offerId, isNull);
  });

  test('kepala lama dipertahankan untuk pembaca lama', () {
    final raw = full.encode(head: 'offer:18|min:800');
    // Pembaca lama memakai split('|').first dan mencari 'min:'.
    expect(raw.split('|').first, 'offer:18');
    expect(raw.split('|').contains('min:800'), isTrue);
    expect(TransferNewsPayload.tryParse(raw)!.playerId, 142);
    expect(TransferNewsPayload.offerIdOf(raw), 18);
  });

  test('payload lama (save lama) → tryParse null, id tetap terbaca', () {
    for (final legacy in [null, 'offer:1', 'offer:7|min:900', 'player:45']) {
      expect(TransferNewsPayload.tryParse(legacy), isNull, reason: legacy);
    }
    expect(TransferNewsPayload.offerIdOf('offer:7|min:900'), 7);
    expect(TransferNewsPayload.offerIdOf('player:45'), isNull);
    expect(TransferNewsPayload.playerIdOf('player:45'), 45);
    expect(TransferNewsPayload.playerIdOf('offer:1'), isNull);
    expect(TransferNewsPayload.offerIdOf(null), isNull);
  });

  test('id dari payload tx tanpa kepala lama', () {
    final raw = full.encode();
    expect(TransferNewsPayload.offerIdOf(raw), 18);
    expect(TransferNewsPayload.playerIdOf(raw), 142);
    expect(
      TransferNewsPayload.playerIdOf(full.encode(head: 'player:142')),
      142,
    );
  });

  test('payload rusak tidak melempar error', () {
    for (final bad in [
      'tx:{bukan json',
      'tx:{"v":1}',
      'tx:{"v":1,"playerId":1,"fromClubId":"a","toClubId":"b","status":"x"}',
      'offer:3|tx:[]',
    ]) {
      expect(TransferNewsPayload.tryParse(bad), isNull, reason: bad);
    }
  });
}
