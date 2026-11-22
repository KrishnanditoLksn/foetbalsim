import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/router.dart';
import '../../app/save_session.dart';
import '../../data/database/save_storage.dart';
import '../../data/repositories/save_summary_repository.dart';

/// Daftar semua save yang tersimpan. Pemain memilih salah satu untuk dimuat.
class LoadGameScreen extends ConsumerStatefulWidget {
  const LoadGameScreen({super.key});

  @override
  ConsumerState<LoadGameScreen> createState() => _LoadGameScreenState();
}

class _LoadGameScreenState extends ConsumerState<LoadGameScreen> {
  bool _loading = true;
  String? _error;
  List<SaveSummary> _saves = const [];
  int? _openingSlot;

  @override
  void initState() {
    super.initState();
    _loadSaves();
  }

  Future<void> _loadSaves() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final slots = await SaveStorage.existingSlots();
      final summaries = <SaveSummary>[];
      for (final slot in slots) {
        final summary = await SaveSummaryRepository.read(slot);
        if (summary != null) summaries.add(summary);
      }
      // Yang terakhir dimainkan ada di atas.
      summaries.sort((a, b) => b.modified.compareTo(a.modified));
      if (!mounted) return;
      setState(() {
        _saves = summaries;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal membaca daftar save: $e';
        _loading = false;
      });
    }
  }

  Future<void> _open(SaveSummary save) async {
    if (_openingSlot != null) return;
    setState(() => _openingSlot = save.slot);
    try {
      await activateSave(ref, save.slot);
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.dashboard, (route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat save: $e')));
    } finally {
      if (mounted) setState(() => _openingSlot = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Muat Karier'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _loadSaves,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_error!, textAlign: TextAlign.center),
        ),
      );
    }
    if (_saves.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Belum ada karier yang tersimpan.\nBuat karier baru dari menu awal.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _saves.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final save = _saves[i];
        final busy = _openingSlot == save.slot;
        return Card(
          child: ListTile(
            leading: CircleAvatar(child: Text('${save.slot}')),
            title: Text(save.managerName),
            subtitle: Text(
              '${save.clubName}\n'
              'Tanggal game: ${_formatDate(save.currentDate)} · '
              'Disimpan: ${_formatDate(save.modified.toLocal())}',
            ),
            isThreeLine: true,
            trailing:
                busy
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.play_arrow),
            onTap: _openingSlot == null ? () => _open(save) : null,
          ),
        );
      },
    );
  }

  static String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${months[d.month - 1]} ${d.year} $hh:$mm';
  }
}
