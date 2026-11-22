import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../core/utils/format_utils.dart';
import '../../core/widgets/club_badge.dart';
import '../../domain/models/game_models.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const _menu = <(String, IconData)>[
    ('Inbox', Icons.inbox),
    ('Skuad', Icons.groups),
    ('Taktik', Icons.sports),
    ('Latihan', Icons.fitness_center),
    ('Transfer', Icons.swap_horiz),
    ('Jadwal', Icons.calendar_month),
    ('Klub', Icons.shield),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(gameStateProvider);

    return stateAsync.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (state) {
        if (state == null) {
          return const Scaffold(
            body: Center(child: Text('Data karier tidak ditemukan.')),
          );
        }
        final clubId = state.clubId;
        final clubAsync =
            clubId == null
                ? const AsyncValue<Club?>.data(null)
                : ref.watch(clubByIdProvider(clubId));
        final club = clubAsync.valueOrNull;

        return Scaffold(
          appBar: AppBar(
            title: Text(club?.name ?? 'Dashboard'),
            actions: [
              if (club != null)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ClubBadge(club: club, size: 36),
                ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: ListTile(
                    title: Text('Manajer ${state.managerName}'),
                    subtitle: Text(
                      'Tanggal: ${_formatDate(state.currentDate)}'
                      '${club == null ? '' : ' · Saldo ${formatMoney(club.balance)}'}',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.2,
                    children: [
                      for (final (label, icon) in _menu)
                        _MenuTile(
                          label: label,
                          icon: icon,
                          onTap: () => _open(context, label),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // CONTINUE sementara nonaktif; diaktifkan di Fase 2.
                const FilledButton(onPressed: null, child: Text('CONTINUE')),
              ],
            ),
          ),
        );
      },
    );
  }

  void _open(BuildContext context, String label) {
    if (label == 'Skuad') {
      Navigator.of(context).pushNamed(AppRoutes.squad);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label akan hadir di fase berikutnya.')),
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
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28),
              const SizedBox(height: 6),
              Text(label, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}
