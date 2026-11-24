import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/providers.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'features/start/start_screen.dart';

void main() {
  runApp(const ProviderScope(child: FutbolApp()));
}

class FutbolApp extends ConsumerWidget {
  const FutbolApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Aksen aplikasi = warna klub yang sedang dilatih.
    final club = ref.watch(ourClubProvider);
    return MaterialApp(
      title: 'Futbol',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.board(club: club),
      initialRoute: AppRoutes.start,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: const StartScreen(),
    );
  }
}
