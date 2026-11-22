import 'dart:math' as math;

/// Generator angka acak deterministik (xorshift32).
///
/// Algoritma ditulis sendiri (bukan `dart:math.Random`) supaya urutan angkanya
/// stabil lintas versi Dart/platform: seed yang sama selalu menghasilkan dunia
/// yang persis sama.
class SeededRandom {
  SeededRandom(int seed) : _state = _normalize(seed);

  static const int _mask32 = 0xFFFFFFFF;
  int _state;

  static int _normalize(int seed) {
    final s = seed & _mask32;
    return s == 0 ? 0x6D2B79F5 : s;
  }

  /// Angka acak 32-bit tanpa tanda.
  int nextU32() {
    var x = _state;
    x ^= (x << 13) & _mask32;
    x ^= x >> 17;
    x ^= (x << 5) & _mask32;
    _state = x & _mask32;
    return _state;
  }

  /// Nilai di rentang [0, 1).
  double nextDouble() => nextU32() / 0x100000000;

  /// Bilangan bulat di rentang [0, max).
  int nextInt(int max) {
    assert(max > 0, 'max harus > 0');
    return (nextDouble() * max).floor();
  }

  /// Bilangan bulat di rentang [min, max] (inklusif).
  int range(int min, int max) => min + nextInt(max - min + 1);

  bool chance(double probability) => nextDouble() < probability;

  T pick<T>(List<T> items) {
    assert(items.isNotEmpty);
    return items[nextInt(items.length)];
  }

  /// Distribusi normal (Box-Muller).
  double gaussian({double mean = 0, double stdDev = 1}) {
    final u1 = math.max(nextDouble(), 1e-12);
    final u2 = nextDouble();
    final z = math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2);
    return mean + stdDev * z;
  }

  /// Fisher-Yates shuffle di tempat.
  void shuffle<T>(List<T> list) {
    for (var i = list.length - 1; i > 0; i--) {
      final j = nextInt(i + 1);
      final tmp = list[i];
      list[i] = list[j];
      list[j] = tmp;
    }
  }
}
