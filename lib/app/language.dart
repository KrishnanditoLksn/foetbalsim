import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../l10n/l10n.dart';

/// Bahasa aplikasi yang dipilih pemain. Nilai awal di-override di `main()`
/// dengan hasil [LanguageStore.load].
final languageProvider = StateNotifierProvider<LanguageController, AppLanguage>(
  (ref) => LanguageController(L10n.current),
);

class LanguageController extends StateNotifier<AppLanguage> {
  LanguageController(super.initial) {
    L10n.current = state;
  }

  Future<void> set(AppLanguage lang) async {
    if (lang == state) return;
    L10n.current = lang;
    state = lang;
    _rebuildAll();
    await LanguageStore.save(lang);
  }

  /// Teks memakai `tr()` global, jadi semua widget perlu dibangun ulang saat
  /// bahasa berganti. Ini tidak mengubah state navigasi atau layar.
  static void _rebuildAll() {
    void visit(Element el) {
      el.markNeedsBuild();
      el.visitChildren(visit);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(visit);
  }
}

/// Menyimpan pilihan bahasa di `settings.json` (terpisah dari file save,
/// karena bahasa berlaku untuk semua karier).
abstract final class LanguageStore {
  @visibleForTesting
  static Future<File> Function()? fileOverride;

  static Future<File> _file() async {
    final override = fileOverride;
    if (override != null) return override();
    final dir = await getApplicationSupportDirectory();
    return File(p.join(dir.path, 'settings.json'));
  }

  /// Bahasa tersimpan; bila belum ada, bahasa perangkat (bila didukung);
  /// selain itu bahasa Inggris.
  static Future<AppLanguage> load() async {
    try {
      final file = await _file();
      if (await file.exists()) {
        final json = jsonDecode(await file.readAsString()) as Map;
        final saved = AppLanguage.fromCode(json['language'] as String?);
        if (saved != null) return saved;
      }
    } catch (e) {
      debugPrint('Gagal membaca pengaturan bahasa: $e');
    }
    return deviceLanguage();
  }

  static AppLanguage deviceLanguage() {
    for (final locale in PlatformDispatcher.instance.locales) {
      final lang = AppLanguage.fromCode(locale.languageCode);
      if (lang != null) return lang;
    }
    return AppLanguage.en;
  }

  static Future<void> save(AppLanguage lang) async {
    try {
      final file = await _file();
      await file.parent.create(recursive: true);
      await file.writeAsString(jsonEncode({'language': lang.code}));
    } catch (e) {
      debugPrint('Gagal menyimpan pengaturan bahasa: $e');
    }
  }
}

/// Tombol pemilih bahasa (ikon + kode bahasa) untuk AppBar atau pojok layar.
class LanguageButton extends ConsumerWidget {
  const LanguageButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(languageProvider);
    return PopupMenuButton<AppLanguage>(
      tooltip: tr('common.language'),
      initialValue: current,
      onSelected: (lang) => ref.read(languageProvider.notifier).set(lang),
      itemBuilder:
          (_) => [
            for (final lang in AppLanguage.values)
              CheckedPopupMenuItem(
                value: lang,
                checked: lang == current,
                child: Text(lang.nativeName),
              ),
          ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.translate, size: 20),
            const SizedBox(width: 6),
            Text(
              current.code.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
