/// Bahasa yang didukung aplikasi. Urutan = urutan di pemilih bahasa.
enum AppLanguage {
  en('en', 'English'),
  id('id', 'Bahasa Indonesia'),
  fr('fr', 'Français');

  const AppLanguage(this.code, this.nativeName);

  /// Kode ISO 639-1, juga dipakai sebagai `Locale(code)`.
  final String code;

  /// Nama bahasa dalam bahasanya sendiri (tidak diterjemahkan).
  final String nativeName;

  /// Bahasa untuk [code]; null bila tidak didukung.
  static AppLanguage? fromCode(String? code) {
    for (final l in values) {
      if (l.code == code) return l;
    }
    return null;
  }
}
