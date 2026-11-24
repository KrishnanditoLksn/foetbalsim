import 'transfer_window.dart';

/// Panas pasar (README_FASE3 B.4 & B.8): naik saat banyak klub mencari posisi
/// yang sama, dan naik tajam di Deadline Day (3 hari terakhir jendela).
abstract final class MarketHeat {
  /// Pengali harga 0,9–1,4.
  static double multiplier({
    required DateTime date,
    required double positionDemand, // 0..1, permintaan posisi pemain
  }) {
    var m = 0.95 + 0.2 * positionDemand.clamp(0, 1);
    if (TransferWindow.isDeadlineDay(date)) m += 0.25;
    return m.clamp(0.9, 1.4).toDouble();
  }

  /// Fase jendela untuk intensitas aktivitas bursa (README_FASE3 B.8).
  static WindowPhase phase(DateTime date) {
    if (!TransferWindow.isOpen(date)) return WindowPhase.closed;
    if (TransferWindow.isDeadlineDay(date)) return WindowPhase.deadlineDay;
    final closes = TransferWindow.status(date).closesOn;
    final days = closes == null ? 0 : closes.difference(date).inDays;
    if (days <= 7) return WindowPhase.lastWeek;
    if (days <= 31) return WindowPhase.middle;
    return WindowPhase.start;
  }
}

/// Fase jendela transfer.
enum WindowPhase { closed, start, middle, lastWeek, deadlineDay }
