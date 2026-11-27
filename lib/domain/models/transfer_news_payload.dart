import 'dart:convert';

import '../enums/squad_status.dart';
import '../enums/transfer.dart';

/// Rincian terstruktur sebuah berita transfer, disimpan di
/// `InboxMessages.payload` agar Inbox bisa menampilkan kartu detail
/// (avatar pemain, klub asal → tujuan, kontrak, biaya, status).
///
/// Format payload: `[kepala lama|]tx:{json}`. Kepala lama (`offer:ID`,
/// `offer:ID|min:GAJI`, `player:ID`) tetap di depan sehingga semua pembaca
/// lama yang memakai `split('|').first` tetap bekerja; segmen `tx:` selalu
/// terakhir. Pesan dari save lama tanpa `tx:` → [tryParse] mengembalikan
/// null dan Inbox memakai dialog teks biasa.
///
/// Data di sini adalah snapshot saat berita dibuat (biaya, kontrak, status).
/// Nama, posisi, CA, dan klub diambil live dari database memakai id.
class TransferNewsPayload {
  const TransferNewsPayload({
    required this.playerId,
    required this.playerName,
    required this.fromClubId,
    required this.toClubId,
    required this.status,
    required this.fee,
    this.transferType,
    this.installmentYears = 1,
    this.sellOnPct = 0,
    this.contractYears,
    this.contractEndDate,
    this.wage,
    this.minWage,
    this.squadStatus,
    this.offerId,
  });

  static const version = 1;
  static const _tag = 'tx:';

  final int playerId;

  /// Cadangan bila pemain tidak ditemukan lagi di database.
  final String playerName;

  /// Klub yang ditinggalkan pemain.
  final String fromClubId;

  /// Klub tujuan pemain.
  final String toClubId;
  final TransferNewsStatus status;

  /// Biaya transfer / nominal tawaran / harga minta (€K).
  final int fee;
  final TransferType? transferType;
  final int installmentYears;
  final int sellOnPct;

  /// Durasi kontrak baru (hanya untuk transfer selesai).
  final int? contractYears;

  /// Akhir kontrak: kontrak baru bila [status] selesai, kontrak saat ini
  /// selain itu.
  final DateTime? contractEndDate;

  /// Gaji per tahun (€K) dari kontrak yang sama dengan [contractEndDate].
  final int? wage;

  /// Gaji minimal yang diminta pemain (negosiasi kontrak).
  final int? minWage;
  final SquadStatus? squadStatus;
  final int? offerId;

  Map<String, Object?> toJson() => {
    'v': version,
    'playerId': playerId,
    'playerName': playerName,
    'fromClubId': fromClubId,
    'toClubId': toClubId,
    'status': status.name,
    'fee': fee,
    if (transferType != null) 'transferType': transferType!.name,
    if (installmentYears != 1) 'installmentYears': installmentYears,
    if (sellOnPct != 0) 'sellOnPct': sellOnPct,
    if (contractYears != null) 'contractYears': contractYears,
    if (contractEndDate != null) 'contractEndDate': _dateOnly(contractEndDate!),
    if (wage != null) 'wage': wage,
    if (minWage != null) 'minWage': minWage,
    if (squadStatus != null) 'squadStatus': squadStatus!.name,
    if (offerId != null) 'offerId': offerId,
  };

  /// Payload siap simpan. [head] = payload lama yang dipertahankan di depan
  /// (mis. `offer:12|min:800`).
  String encode({String? head}) {
    final tx = '$_tag${jsonEncode(toJson())}';
    return head == null ? tx : '$head|$tx';
  }

  static TransferNewsPayload fromJson(Map<String, Object?> j) {
    T? byName<T extends Enum>(List<T> values, Object? name) {
      for (final v in values) {
        if (v.name == name) return v;
      }
      return null;
    }

    final status = byName(TransferNewsStatus.values, j['status']);
    if (status == null) throw FormatException('status: ${j['status']}');
    final end = j['contractEndDate'] as String?;
    return TransferNewsPayload(
      playerId: (j['playerId'] as num).toInt(),
      playerName: j['playerName'] as String? ?? '',
      fromClubId: j['fromClubId'] as String,
      toClubId: j['toClubId'] as String,
      status: status,
      fee: (j['fee'] as num?)?.toInt() ?? 0,
      transferType: byName(TransferType.values, j['transferType']),
      installmentYears: (j['installmentYears'] as num?)?.toInt() ?? 1,
      sellOnPct: (j['sellOnPct'] as num?)?.toInt() ?? 0,
      contractYears: (j['contractYears'] as num?)?.toInt(),
      contractEndDate: end == null ? null : DateTime.parse('${end}T00:00:00Z'),
      wage: (j['wage'] as num?)?.toInt(),
      minWage: (j['minWage'] as num?)?.toInt(),
      squadStatus: byName(SquadStatus.values, j['squadStatus']),
      offerId: (j['offerId'] as num?)?.toInt(),
    );
  }

  /// Payload `tx:` dari [raw], atau null bila tidak ada / rusak (save lama).
  static TransferNewsPayload? tryParse(String? raw) {
    if (raw == null) return null;
    final at = raw.startsWith(_tag) ? 0 : raw.indexOf('|$_tag');
    if (at < 0) return null;
    final json = raw.substring(at == 0 ? _tag.length : at + 1 + _tag.length);
    try {
      return fromJson((jsonDecode(json) as Map).cast<String, Object?>());
    } catch (_) {
      return null;
    }
  }

  /// Id tawaran dari payload lama (`offer:ID…`) maupun `tx:`.
  static int? offerIdOf(String? raw) {
    final head = _legacyHead(raw);
    if (head != null && head.startsWith('offer:')) {
      return int.tryParse(head.substring('offer:'.length));
    }
    return tryParse(raw)?.offerId;
  }

  /// Id pemain dari payload lama (`player:ID`) maupun `tx:`.
  static int? playerIdOf(String? raw) {
    final head = _legacyHead(raw);
    if (head != null && head.startsWith('player:')) {
      return int.tryParse(head.substring('player:'.length));
    }
    return tryParse(raw)?.playerId;
  }

  static String? _legacyHead(String? raw) {
    if (raw == null || raw.startsWith(_tag)) return null;
    return raw.split('|').first;
  }

  static String _dateOnly(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final u = d.toUtc();
    return '${u.year.toString().padLeft(4, '0')}-${two(u.month)}-${two(u.day)}';
  }
}
