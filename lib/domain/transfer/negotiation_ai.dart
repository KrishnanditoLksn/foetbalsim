import 'club_ai_profile.dart';

/// Keputusan klub penjual atas sebuah tawaran.
enum NegotiationVerdict { accept, counter, reject }

class NegotiationResult {
  const NegotiationResult(this.verdict, {this.counterFee, this.reason});

  final NegotiationVerdict verdict;
  final int? counterFee; // untuk counter
  final String? reason; // untuk penolakan
}

/// Evaluasi tawaran (README_FASE3 B.5). Aturan:
/// - < 70% harga minta: ditolak.
/// - 70–99%: counter-offer (mendekati harga minta sesuai `negotiationSkill`).
/// - ≥ harga minta: diterima.
/// - Pemain inti tanpa pengganti: butuh ≥ 110% harga minta.
///
/// Untuk tawaran user, hasil `counter` membuka Ruang Negosiasi
/// (`AgentNegotiator`); [NegotiationResult.counterFee] hanya dipakai bursa
/// antar-klub AI.
abstract final class NegotiationAi {
  static NegotiationResult evaluate({
    required int offer,
    required int ask,
    required ClubAiProfile seller,
    required bool isIndispensable,
  }) {
    final ratio = offer / ask;
    if (isIndispensable && ratio < 1.1) {
      return NegotiationResult(
        NegotiationVerdict.reject,
        reason: 'Pemain inti, tidak dijual di bawah '
            '${_fmt((ask * 1.1).round())}.',
      );
    }
    if (ratio < 0.7) {
      return const NegotiationResult(
        NegotiationVerdict.reject,
        reason: 'Tawaran terlalu rendah.',
      );
    }
    if (ratio >= 1.0) return const NegotiationResult(NegotiationVerdict.accept);
    // Counter: makin pintar negosiator, makin mendekati harga minta.
    final closeness = 0.9 + 0.09 * seller.negotiationSkill / 100;
    final counter = (ask * closeness).round();
    return NegotiationResult(NegotiationVerdict.counter, counterFee: counter);
  }

  static String _fmt(int k) => k >= 1000
      ? '€${(k / 1000).toStringAsFixed(1)} jt'
      : '€$k rb';
}
