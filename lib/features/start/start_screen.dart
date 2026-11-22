import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../app/save_session.dart';
import '../../data/database/save_storage.dart';

class StartScreen extends ConsumerStatefulWidget {
  const StartScreen({super.key});

  @override
  ConsumerState<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends ConsumerState<StartScreen> {
  bool _busy = false;

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  /// Dicek saat tombol ditekan (bukan saat layar dibuka), supaya selalu
  /// membaca kondisi terbaru setelah karier baru dibuat.
  Future<void> _continueCareer() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final slot = await SaveStorage.latestSlot();
      if (slot == null) {
        _showMessage('Belum ada karier yang tersimpan.');
        return;
      }
      await activateSave(ref, slot);
      final state = await ref.read(gameStateRepositoryProvider).load();
      if (!mounted) return;
      if (state == null) {
        _showMessage('Save slot $slot rusak: data karier tidak ditemukan.');
        return;
      }
      Navigator.of(context).pushNamed(AppRoutes.dashboard);
    } catch (e) {
      _showMessage('Gagal membuka karier: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

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
                        _busy
                            ? null
                            : () => Navigator.of(
                              context,
                            ).pushNamed(AppRoutes.newCareer),
                    child: const Text('Karier Baru'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _busy ? null : _continueCareer,
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
