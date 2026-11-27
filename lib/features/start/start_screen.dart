import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/language.dart';
import '../../app/router.dart';
import '../../app/save_session.dart';
import '../../app/theme.dart';
import '../../data/database/save_storage.dart';
import '../../data/repositories/save_summary_repository.dart';
import '../../l10n/l10n.dart';

/// Menu awal: papan dengan garis lapangan dari kapur, nama permainan, lalu
/// karier terakhir (bila ada), karier baru, dan semua save.
class StartScreen extends ConsumerStatefulWidget {
  const StartScreen({super.key});

  @override
  ConsumerState<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends ConsumerState<StartScreen> {
  late Future<SaveSummary?> _latest = _loadLatest();
  bool _opening = false;

  static Future<SaveSummary?> _loadLatest() async {
    try {
      final slot = await SaveStorage.latestSlot();
      if (slot == null) return null;
      return await SaveSummaryRepository.read(slot);
    } catch (_) {
      return null; // save rusak: bagian ini tidak ditampilkan
    }
  }

  /// Dipanggil setelah kembali dari layar lain (mis. save dihapus).
  void _refresh() => setState(() => _latest = _loadLatest());

  Future<void> _push(String route) async {
    await Navigator.of(context).pushNamed(route);
    if (mounted) _refresh();
  }

  Future<void> _continue(SaveSummary save) async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      await activateSave(ref, save.slot);
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.dashboard, (_) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('start.openFailed', {'error': '$e'}))),
      );
      setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: _PitchLines())),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/icon/app_logo.png',
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Futbol',
                              style: TextStyle(
                                fontFamily: Fonts.condensed,
                                fontSize: 72,
                                height: 0.95,
                                fontWeight: FontWeight.w700,
                                color: Chalk.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tr('start.tagline'),
                        style: TextStyle(color: Chalk.dim, fontSize: 16),
                      ),
                      const SizedBox(height: 56),
                      FutureBuilder<SaveSummary?>(
                        future: _latest,
                        builder: (context, snap) {
                          final save = snap.data;
                          if (save == null) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: _LastCareer(
                              save: save,
                              opening: _opening,
                              onTap: () => _continue(save),
                            ),
                          );
                        },
                      ),
                      FilledButton(
                        onPressed:
                            _opening ? null : () => _push(AppRoutes.newCareer),
                        child: Text(tr('start.newCareer')),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed:
                            _opening ? null : () => _push(AppRoutes.loadGame),
                        child: Text(tr('start.allSaves')),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Di atas isi agar tetap bisa diketuk.
          const Positioned(
            top: 0,
            right: 0,
            child: SafeArea(child: LanguageButton()),
          ),
        ],
      ),
    );
  }
}

/// Karier terakhir yang dimainkan, siap dilanjutkan dengan satu ketukan.
class _LastCareer extends StatelessWidget {
  const _LastCareer({
    required this.save,
    required this.opening,
    required this.onTap,
  });

  final SaveSummary save;
  final bool opening;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Material(
      color: Chalk.boardRaised,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: opening ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('start.continue'),
                      style: TextStyle(color: Chalk.dim, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      save.clubName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: Fonts.condensed,
                        fontSize: 30,
                        height: 1.05,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${tr('common.manager', {'name': save.managerName})}, '
                      '${formatDate(save.currentDate)}',
                      style: TextStyle(color: Chalk.dim, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              opening
                  ? const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                  : Icon(Icons.play_arrow_rounded, size: 40, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}

/// Garis lapangan dari kapur yang pudar: garis tengah, lingkaran tengah,
/// dan kotak penalti, setengah terlihat di bawah layar.
class _PitchLines extends CustomPainter {
  const _PitchLines();

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Chalk.white.withValues(alpha: 0.07)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
    final w = size.width;
    final h = size.height;
    // Garis tengah di bawah tombol, agar lingkaran tidak menabrak isi.
    final midY = h * 0.9;
    // Garis tengah dan lingkaran tengah.
    canvas.drawLine(Offset(0, midY), Offset(w, midY), paint);
    canvas.drawCircle(Offset(w / 2, midY), w * 0.24, paint);
    canvas.drawCircle(
      Offset(w / 2, midY),
      3,
      paint..style = PaintingStyle.fill,
    );
    paint.style = PaintingStyle.stroke;
    // Kotak penalti di atas.
    canvas.drawRect(Rect.fromLTWH(w * 0.18, -2, w * 0.64, h * 0.16), paint);
    canvas.drawRect(Rect.fromLTWH(w * 0.36, -2, w * 0.28, h * 0.06), paint);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w / 2, h * 0.11), radius: w * 0.14),
      0.6,
      1.94,
      false,
      paint,
    );
    // Garis samping.
    canvas.drawLine(const Offset(14, 0), Offset(14, h), paint);
    canvas.drawLine(Offset(w - 14, 0), Offset(w - 14, h), paint);
  }

  @override
  bool shouldRepaint(_PitchLines oldDelegate) => false;
}
