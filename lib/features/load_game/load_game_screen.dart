import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/router.dart';
import '../../app/save_session.dart';
import '../../data/database/save_storage.dart';
import '../../data/repositories/save_summary_repository.dart';

/// Daftar semua save yang tersimpan. Pemain memilih salah satu untuk dimuat
/// atau menghapusnya untuk mengosongkan slot.
class LoadGameScreen extends ConsumerStatefulWidget {
  const LoadGameScreen({super.key});

  @override
  ConsumerState<LoadGameScreen> createState() => _LoadGameScreenState();
}

class _LoadGameScreenState extends ConsumerState<LoadGameScreen> {
  bool _loading = true;
  String? _error;
  List<SaveSummary> _saves = const [];

  /// Slot yang filenya ada tetapi tidak berisi karier yang bisa dibaca.
  /// Tetap ditampilkan agar bisa dihapus (dan tetap dihitung terpakai).
  List<int> _brokenSlots = const [];
  int? _openingSlot;
  int? _deletingSlot;

  bool get _busy => _openingSlot != null || _deletingSlot != null;
  int get _usedSlots => _saves.length + _brokenSlots.length;

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
      final broken = <int>[];
      for (final slot in slots) {
        SaveSummary? summary;
        try {
          summary = await SaveSummaryRepository.read(slot);
        } catch (_) {
          summary = null;
        }
        if (summary == null) {
          broken.add(slot);
        } else {
          summaries.add(summary);
        }
      }
      // Yang terakhir dimainkan ada di atas.
      summaries.sort((a, b) => b.modified.compareTo(a.modified));
      if (!mounted) return;
      setState(() {
        _saves = summaries;
        _brokenSlots = broken;
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
    if (_busy) return;
    setState(() => _openingSlot = save.slot);
    try {
      await activateSave(ref, save.slot);
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.dashboard, (_) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat save: $e')));
    } finally {
      if (mounted) setState(() => _openingSlot = null);
    }
  }

  /// Konfirmasi lalu hapus slot. [description] menjelaskan isi slot di dialog.
  Future<void> _confirmAndDelete(int slot, String description) async {
    if (_busy) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          title: const Text('Hapus save?'),
          content: Text(
            'Slot $slot · $description\n\n'
            'Save ini akan dihapus permanen dan tidak bisa dikembalikan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _deletingSlot = slot);
    try {
      await deleteSave(ref, slot);
      messenger.showSnackBar(
        SnackBar(content: Text('Save slot $slot berhasil dihapus.')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Gagal menghapus save slot $slot: $e')),
      );
    } finally {
      if (mounted) setState(() => _deletingSlot = null);
    }
    if (mounted) await _loadSaves();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _loading
              ? 'Muat Karier'
              : 'Muat Karier ($_usedSlots/${SaveStorage.maxSlots})',
        ),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh),
            onPressed: _loading || _busy ? null : _loadSaves,
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
    if (_saves.isEmpty && _brokenSlots.isEmpty) {
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

    final cards = <Widget>[
      for (final save in _saves) _saveCard(save),
      for (final slot in _brokenSlots) _brokenCard(slot),
    ];
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: cards.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) => cards[i],
    );
  }

  Widget _saveCard(SaveSummary save) {
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _deleteButton(save.slot, '${save.managerName} · ${save.clubName}'),
            _openingSlot == save.slot
                ? const _SmallSpinner()
                : const Icon(Icons.play_arrow),
          ],
        ),
        onTap: _busy ? null : () => _open(save),
      ),
    );
  }

  Widget _brokenCard(int slot) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text('$slot')),
        title: const Text('Save tidak dapat dibaca'),
        subtitle: const Text(
          'File save ada tetapi datanya rusak atau belum lengkap. '
          'Hapus untuk mengosongkan slot ini.',
        ),
        trailing: _deleteButton(slot, 'save rusak'),
      ),
    );
  }

  Widget _deleteButton(int slot, String description) {
    if (_deletingSlot == slot) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14),
        child: _SmallSpinner(),
      );
    }
    return IconButton(
      icon: const Icon(Icons.delete_outline),
      tooltip: 'Hapus save',
      color: Theme.of(context).colorScheme.error,
      onPressed: _busy ? null : () => _confirmAndDelete(slot, description),
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

class _SmallSpinner extends StatelessWidget {
  const _SmallSpinner();

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 20,
    height: 20,
    child: CircularProgressIndicator(strokeWidth: 2),
  );
}
