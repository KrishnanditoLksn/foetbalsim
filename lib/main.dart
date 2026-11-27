import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/language.dart';
import 'app/providers.dart';
import 'app/rebuild_all.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'features/start/start_screen.dart';
import 'l10n/l10n.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final language = await LanguageStore.load();
  L10n.current = language;
  runApp(
    ProviderScope(
      overrides: [
        languageProvider.overrideWith((ref) => LanguageController(language)),
      ],
      child: const FutbolApp(),
    ),
  );
}

class FutbolApp extends ConsumerWidget {
  const FutbolApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Warna papan = identitas klub yang sedang dilatih.
    final club = ref.watch(ourClubProvider);
    final language = ref.watch(languageProvider);
    final previous = Chalk.palette;
    final theme = AppTheme.board(club: club);
    if (Chalk.palette != previous) {
      // Widget membaca `Chalk.*` langsung (bukan lewat Theme), jadi semua
      // widget perlu dibangun ulang dengan palet baru.
      WidgetsBinding.instance.addPostFrameCallback((_) => rebuildAllWidgets());
    }
    return MaterialApp(
      title: 'Futbol',
      debugShowCheckedModeBanner: false,
      theme: theme,
      // Locale untuk teks bawaan Material (tooltip, dialog tanggal, dll.).
      locale: Locale(language.code),
      supportedLocales: [for (final l in AppLanguage.values) Locale(l.code)],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      initialRoute: AppRoutes.start,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: const StartScreen(),
    );
  }
}
