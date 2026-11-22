import 'package:flutter/material.dart';

import '../../app/router.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.sports_soccer,
                    size: 96,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'FUTBOL',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 48),
                  FilledButton(
                    onPressed:
                        () => Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.newCareer),
                    child: const Text('Karier Baru'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed:
                        () =>
                            Navigator.of(context).pushNamed(AppRoutes.loadGame),
                    child: const Text('Lanjutkan'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
